ad_page_contract {
    @param address_id a stored address
    @param tax_exempt_p a flag to indicate if the customer is tax exempt
    @param usca_p User session started or not

    @author
    @creation-date
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse <bart.teeuwisse@7-sisters.com>
    @revision-date April 2002

} {
    address_id:optional,naturalnum
    tax_exempt_p:optional
    usca_p:optional
    quantity:array,optional
}

ec_redirect_to_https_if_possible_and_necessary

# we need them to be logged in

set user_id [ad_verify_and_get_user_id]
if {$user_id == 0} {
    set return_url "[ad_conn url]"
    ad_returnredirect "/register?[export_url_vars return_url]"
    return
}

# user sessions:
# 1. get user_session_id from cookie
# 2. if user has no session (i.e. user_session_id=0), attempt to set it if it hasn't been
#    attempted before
# 3. if it has been attempted before, give them message that we can't do shopping carts
#    without cookies

set user_session_id [ec_get_user_session_id]
ec_create_new_session_if_necessary [export_url_vars address_id]

# Make sure they have an in_basket order, otherwise they've probably
# gotten here by pushing Back, so return them to index.tcl

set success_p [db_0or1row get_order_id_and_order_owner "
    select order_id, user_id as order_owner 
    from ec_orders 
    where user_session_id=:user_session_id 
    and order_state='in_basket' "]
if { ! $success_p } {
    
    # No rows came back, so they probably got here by pushing "Back",
    # so just redirect them to index.tcl

    ad_returnredirect [ec_url]index.tcl
    return
} 

if { $order_owner != $user_id } {

    # make sure the order belongs to this user_id (why?  because
    # before this point there was no personal information associated
    # with the order (so it was fine to go by user_session_id), but
    # now there is, and we don't want someone messing with their
    # user_session_id cookie and getting someone else's order)

    # If they get here, either they managed to skip past checkout.tcl,
    # or they messed w/their user_session_id cookie;

    ad_returnredirect [ec_securelink [ec_url]checkout.tcl]
    return
}

# make sure there's something in their shopping cart, otherwise
# redirect them to their shopping cart which will tell them that it's
# empty.

if { [db_string get_ec_item_count "
    select count(*) 
    from ec_items 
    where order_id=:order_id"] == 0 } {
    ad_returnredirect [ec_url]shopping-cart
    return
}

db_0or1row shipping_avail "
    select p.no_shipping_avail_p
    from ec_items i, ec_products p
    where i.product_id = p.product_id
    and p.no_shipping_avail_p = 'f' 
    and i.order_id = :order_id
    group by no_shipping_avail_p"

# Either address_id should be a form variable, or it should already be
# in the database for this order

# Make sure address_id, if it exists, belongs to them, otherwise
# they've probably gotten here by form surgery, in which case send
# them back to checkout.tcl if it is theirs, put it into the database
# for this order

# If address_id doesn't exist, make sure there is an address for this
# order, otherwise they've probably gotten here via url surgery, so
# redirect them to checkout.tcl

if { [info exists address_id] && ![empty_string_p $address_id] } {
    set n_this_address_id_for_this_user [db_string get_an_address_id "
	select count(*) 
	from ec_addresses 
	where address_id=:address_id 
	and user_id=:user_id"]
    if {$n_this_address_id_for_this_user == 0} {
	ad_returnredirect [ec_securelink [ec_url]checkout]
	return
    }

    # It checks out ok

    db_dml update_ec_order_address "
	update ec_orders 
	set shipping_address=:address_id 
	where order_id=:order_id"
} else {
    set address_id [db_string  get_address_id "
	select shipping_address 
	from ec_orders 
	where order_id=:order_id" -default ""]
    if { [empty_string_p $address_id] } {

	# No shipping address is needed if the order only consists of
	# soft goods not requiring shipping.

	if {[info exists no_shipping_avail_p] && [string equal $no_shipping_avail_p "f"]} {
	    ad_returnredirect [ec_securelink [ec_url]checkout]
	    return
	}
    }
}

# Everything is ok now; the user has a non-empty in_basket order and
# an address associated with it, so now get the other necessary
# information

set form_action [ec_securelink [ec_url]process-order-quantity-shipping]

if {[info exists no_shipping_avail_p] && [string equal $no_shipping_avail_p "f"]} {

    # Check if a shipping gateway has been selected.

    set shipping_gateway [ad_parameter ShippingGateway ecommerce]
    if {[acs_sc_binding_exists_p ShippingGateway $shipping_gateway]} {

	# Replace the default ecommerce shipping calculations with the
	# charges from the shipping gateway.

	db_1row select_shipping_address "
	    select country_code, zip_code 
	    from ec_addresses
	    where address_id = :address_id"

	# Calculate the total value of the shipment.

	set shipment_value 0
	db_foreach select_hard_goods "
	    select i.product_id, i.color_choice, i.size_choice, i.style_choice, count(*) as item_count, u.offer_code
	    from ec_products p, ec_items i
	    left join ec_user_session_offer_codes u on (u.product_id = i.product_id and u.user_session_id = :user_session_id)
	    where i.product_id = p.product_id
	    and p.no_shipping_avail_p = 'f' 
	    and i.order_id = :order_id
	    group by i.product_id, i.color_choice, i.size_choice, i.style_choice, u.offer_code" {

	    # If the quantity was altered in the previous step then
	    # use the new quantity instead of the number of items in
	    # the database.

	    if {[info exists quantity]} {
		set item_price [lindex [ec_lowest_price_and_price_name_for_an_item $product_id $user_id $offer_code] 0]
		foreach {item_name item_quantity} [array get quantity [list $product_id*]] {
		    set shipment_value [expr $shipment_value + ((($item_quantity != $item_count) ? $item_quantity : $item_count) * $item_price)]
		}
	    } else {
		set shipment_value [expr $shipment_value + [lindex [ec_lowest_price_and_price_name_for_an_item $product_id $user_id $offer_code] 0]]
	    }
	}
	set value_currency_code [ad_parameter Currency ecommerce]
	set weight_unit_of_measure [ad_parameter WeightUnits ecommerce]

	append shipping_options "
	    <p><b>Available shipping methods:</b></p>
	    <table>"

	# Get the list of services and their charges sorted on
	# charges.

	set rates_and_services [lsort -index 1 -real \
				    [acs_sc_call "ShippingGateway" "RatesAndServicesSelection" \
					 [list "" "" "$country_code" "$zip_code" "$shipment_value" "$value_currency_code" "" "$weight_unit_of_measure"] \
					 "$shipping_gateway"]]

	# Present the available shipping services to the user with the
	# cheapest service selected.

	set cheapest_service true
	foreach service $rates_and_services {
	    array set rate_and_service $service
	    set total_charges $rate_and_service(total_charges)
	    set service_code $rate_and_service(service_code)
	    set service_description [acs_sc_call "ShippingGateway" "ServiceDescription" \
					 "$service_code" \
					 "$shipping_gateway"]
	    append shipping_options " 
		<tr>
		  <td>
		    <input type=\"radio\" name=\"shipping_method\" value=\"[list service_description  $service_description total_charges $total_charges]\""
 	    if {$cheapest_service} {
 		append shipping_options "checked"
 		set cheapest_service false
 	    }
	    append shipping_options "
		>$service_description 
		  </td>
		  <td width=\"30\">
		  </td>
		  <td>
		    [string map {USD $} $value_currency_code]
		  </td>
                  <td align=\"right\">
		    $total_charges
		  </td>
		<tr>"
	}
	append shipping_options "</table>"

	# Add a flag to the export parameters to indicate that a
	# shipping gateway is in use.

 	set shipping_gateway true
 	append shipping_options "[export_form_vars shipping_gateway]"

    } else {
	set shipping_options "
	    <p><b>Available shipping methods:</b></p>
	    <p><input type=radio name=shipping_method value=\"standard\" checked>Standard Shipping<br>"

	if { [ad_parameter -package_id [ec_id] ExpressShippingP ecommerce] } {
	    append shipping_options "
		<input type=radio name=shipping_method value=\"express\">Express<br>"
	}
	if { [ad_parameter -package_id [ec_id] PickupP ecommerce] } {
	    append shipping_options "
		<input type=radio name=shipping_method value=\"pickup\">Pickup</p>"
	}
    }
} else {
    # User has no items that require shipping. Redirect to
    # process-order-quantity-shipping so that prices
    # for items can be inserted into ec_items.
    ad_returnredirect "[ec_securelink [ec_url]process-order-quantity-shipping]"
}


# Export the quantity array if one was passed on from checkout-2

if {[info exists quantity]} {
    foreach name [array names quantity] {
	append shipping_options "<p><input type=\"hidden\" name=\"quantity.$name\" value=\"[lindex [array get quantity $name] 1]\"></p>"
    }
}

# Export the tax exempt flag if one was passed on from checkout-2

if {[info exists tax_exempt_p]} {
    append shipping_options "[export_form_vars tax_exempt_p]"
}

db_release_unused_handles
