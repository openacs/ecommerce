ad_page_contract {

    Void items.

    @author Eve Andersson (eveander@arsdigita.com)
    @creation-date Summer 1999
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @revision-date April 2002

} {
    order_id:integer,notnull
    product_id:integer,notnull
    item_id:multiple,optional
}

ad_require_permission [ad_conn package_id] admin

set customer_service_rep [ad_get_user_id]

# See if there's a gift certificate amount applied to this order
# that's being tied up by unshipped items, in which case we may need
# to reinstate some or all of it.

# The equations are:
# (tied up g.c. amount) = (g.c. bal applied to order) - (amount paid for shipped items)
#                         + (amount refunded for shipped items)
# (amount to be reinstated for to-be-voided items) = (tied up g.c. amount)
#                                                     - (total cost of unshipped items)
#                                                     + (cost of to-be-voided items)
#
# So, (amount to be reinstated) = (g.c. bal applied to order) - (amount paid for shipped items)
# + (amount refunded for shipped items) - (total cost of unshipped items) + cost of to-be-voided items)
# = (g.c. bal applied to order) - (total amount for all nonvoid items in the order, incl the ones that are about to be voided)
#   + (total amount refunded on nonvoid items)
#   + (cost of to-be-voided items)
# = (g.c. bal applied to order) - (total amount for all nonvoid items in the order after these are voided)
#   + total amount refunded on nonvoid items

# This equation is now officially simple to solve.  G.c. balance
# should be calculated first, then things should be voided, then final
# calculation should be made and g.c.'s should be reinstated.

db_transaction {

    set gift_certificate_amount [db_string gift_certificate_amount_select "
	select ec_order_gift_cert_amount(:order_id) 
	from dual"]

    # See if there's more than one item in this order with that
    # order_id & product_id

    set n_items [db_string num_items_select "
	select count(*) 
	from ec_items
	where order_id = :order_id 
	and product_id = :product_id"]

    if { $n_items > 1 } {

	# Make sure they checked at least one checkbox

	set item_id_list $item_id
	if { [llength $item_id_list] == 1 && [lindex $item_id_list 0] == 0 } {
	    ad_return_complaint 1 "<li>You didn't check off any items.</li>"
	    return
	}
	db_dml item_state_update "
	    update ec_items 
	    set item_state = 'void', voided_date = sysdate, voided_by = :customer_service_rep 
	    where item_id in ([join $item_id_list ", "])"
    } else {
	db_dml item_state_update2 "
	    update ec_items
	    set item_state = 'void', voided_date = sysdate, voided_by = :customer_service_rep
	    where order_id = :order_id
	    and product_id = :product_id"
    }

    set amount_charged_minus_refunded_for_nonvoid_items [db_string amount_charged_minus_refunded_for_nonvoid_items_select "
	select nvl(sum(nvl(price_charged,0)) + sum(nvl(shipping_charged,0)) + sum(nvl(price_tax_charged,0)) + sum(nvl(shipping_tax_charged,0)) - sum(nvl(price_refunded,0)) - 
		   sum(nvl(shipping_refunded,0)) + sum(nvl(price_tax_refunded,0)) - sum(nvl(shipping_tax_refunded,0)),0) 
	from ec_items 
	where item_state <> 'void' 
	and order_id = :order_id"]

    set certificate_amount_to_reinstate [expr $gift_certificate_amount - $amount_charged_minus_refunded_for_nonvoid_items]

    if { $certificate_amount_to_reinstate > 0 } {
	set certs_to_reinstate_list [list]
	set certs_to_reinstate_list [db_list certs_to_reinstate_list_select "
	    select u.gift_certificate_id
	    from ec_gift_certificate_usage u, ec_gift_certificates c
	    where u.gift_certificate_id = c.gift_certificate_id
	    and u.order_id = :order_id
	    order by expires desc"]

	# The amount used on that order

	set certificate_amount_used [db_string certificate_amount_used_select "
	    select ec_order_gift_cert_amount(:order_id) 
	    from dual"]

	if { $certificate_amount_used < $certificate_amount_to_reinstate } {
	    db_dml problems_log_insert "
		insert into ec_problems_log
		(problem_id, problem_date, problem_details, order_id)
		values
		(ec_problem_id_sequence.nextval, sysdate, 'We were unable to reinstate the customer''s gift certificate balance because the amount to be reinstated was larger than the original amount used.  This shouldn''t have happened unless there was a programming error or unless the database was incorrectly updated manually.  The voiding of this order has been aborted.', :order_id)"
	    ad_return_error "Gift Certificate Error" "
		<p>We were unable to reinstate the customer's gift certificate balance because the amount to be reinstated was larger than the original amount used.  
		  This shouldn't have happened unless there was a programming error or unless the database was incorrectly updated manually.</p>
		<p>The voiding of this order has been aborted.  This has been logged in the problems log.</p>"
	    return
	} else {

	    # Go through and reinstate certificates in order; it's not
	    # so bad to loop through all of them because I don't
	    # expect there to be many

	    set amount_to_reinstate $certificate_amount_to_reinstate
	    foreach cert $certs_to_reinstate_list {
		if { $amount_to_reinstate > 0 } {
		    
		    # Any amount up to the original amount used on
		    # this order can be reinstated

		    set reinstatable_amount [db_string reinstatable_amount_select "
			select ec_one_gift_cert_on_one_order(:cert,:order_id) 
			from dual"]

		    if { $reinstatable_amount > 0 } {
			set iteration_reinstate_amount [ec_min $reinstatable_amount $amount_to_reinstate]
			db_dml reinstate_gift_certificate_insert "
			    insert into ec_gift_certificate_usage
			    (gift_certificate_id, order_id, amount_reinstated, reinstated_date)
			    values
			    (:cert, :order_id, :iteration_reinstate_amount, sysdate)"
			set amount_to_reinstate [expr $amount_to_reinstate - $iteration_reinstate_amount]
		    }
		}
	    }
	}
    }
}

# Check if a shipping gateway has been selected.

set shipping_gateway [ad_parameter ShippingGateway]
if {[acs_sc_binding_exists_p ShippingGateway $shipping_gateway]} {

    # Replace the default ecommerce shipping calculations with the
    # charges from the shipping gateway. Contact the shipping
    # gateway to recalculate the total shipping charges.

    db_1row select_shipping_address "
	select country_code, zip_code 
	from ec_addresses a, ec_orders o
	where address_id = o.shipping_address
	and o.order_id = :order_id"

    # Calculate the total value of the shipment.

    set shipment_value [db_string select_shipment_value "
	select sum(coalesce(i.price_charged, 0))
	from ec_products p, ec_items i
	where i.product_id = p.product_id
	and p.no_shipping_avail_p = 'f' 
	and i.item_state not in ('void', 'received_back', 'expired')
	and i.order_id = :order_id"]
    set value_currency_code [ad_parameter Currency]
    set weight_unit_of_measure [ad_parameter WeightUnits]

    # Get the list of services and their charges.

    set rates_and_services [acs_sc_call "ShippingGateway" "RatesAndServicesSelection" \
				[list "" "" "$country_code" "$zip_code" "$shipment_value" "$value_currency_code" "" "$weight_unit_of_measure"] \
				"$shipping_gateway"]

    # Find the charges for the selected service for the order.

    set shipping_method [db_string shipping_method_select "
	select shipping_method
	from ec_orders 
	where order_id = :order_id"]

    foreach service $rates_and_services {
	array set rate_and_service $service
	set order_shipping_cost $rate_and_service(total_charges)
	set service_code $rate_and_service(service_code)
	set service_description [acs_sc_call "ShippingGateway" "ServiceDescription" \
				     "$service_code" \
				     "$shipping_gateway"]

	# Unfortunately checking on the description of the
	# shipping service is required as only the description is
	# stored with the order as the shipping method.

	if {[string equal $service_description $shipping_method]} {
	    break
	} 
    }

    # Calculate the tax on shipping and update the shipping cost
    # of the order.

    set tax_on_order_shipping_cost [db_string get_shipping_tax "
	select ec_tax(0, :order_shipping_cost, :order_id)"]

    db_dml set_shipping_charges "
	update ec_orders 
	set shipping_charged = round(:order_shipping_cost, 2), shipping_tax_charged = round(:tax_on_order_shipping_cost, 2) 
	where order_id=:order_id"

}

ad_returnredirect "one?[export_url_vars order_id]"
