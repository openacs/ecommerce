ad_page_contract {

    Actually add the items.

    @author Eve Andersson (eveander@arsdigita.com)
    @creation-date Summer 1999
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @revision-date April 2002

} {
    item_id:integer,notnull
    order_id:integer,notnull
    product_id:integer,notnull
    color_choice
    size_choice
    style_choice
    price_charged
    price_name
}

ad_require_permission [ad_conn package_id] admin

# Double-click protection

if { [db_string doublclick_select "
    select count(*) 
    from ec_items
    where item_id = :item_id"] > 0 } {
    ad_returnredirect "one?[export_url_vars order_id]"
    ad_script_abort
}

# Must have associated credit card

if {[empty_string_p [db_string creditcard_id_select "
    select creditcard_id
    from ec_orders
    where order_id = :order_id"]]} {
    ad_return_error "Unable to add items to this order." "
       <p>This order does not have an associated credit card, so new items cannot be added.</p>
       <p>Please create a new order instead.</p>"
    ad_script_abort
}

set shipping_method [db_string shipping_method_select "
    select shipping_method
    from ec_orders 
    where order_id = :order_id"]

db_transaction {
    db_dml ec_items_insert "
	insert into ec_items
	(item_id, product_id, color_choice, size_choice, style_choice, order_id, in_cart_date, item_state, price_charged, price_name)
	values
	(:item_id, :product_id, :color_choice, :size_choice, :style_choice, :order_id, sysdate, 'to_be_shipped', :price_charged, :price_name)"

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
	set value_currency_code [ad_parameter Currency ecommerce]
	set weight_unit_of_measure [ad_parameter WeightUnits ecommerce]

	# Get the list of services and their charges.

	set rates_and_services [acs_sc_call "ShippingGateway" "RatesAndServicesSelection" \
				    [list "" "" "$country_code" "$zip_code" "$shipment_value" "$value_currency_code" "" "$weight_unit_of_measure"] \
				    "$shipping_gateway"]

	# Find the charges for the selected service for the order.

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

    } else {
    
	# I calculate the shipping after it's inserted because this
	# procedure goes and checks whether this is the first instance
	# of this product in this order.  I know it's non-ideal
	# efficiency-wise, but this procedure (written for the user
	# pages) # is already written and it works.

	set shipping_price [ec_shipping_price_for_one_item $item_id $product_id $order_id $shipping_method]
	
	db_dml ec_items_update "
	    update ec_items 
	    set shipping_charged = :shipping_price 
	    where item_id = :item_id"

    }
}

ad_returnredirect "one?[export_url_vars order_id]"
