ad_page_contract {

    Updates quantities, sets the shipping method,
    and finalizes the prices (inserts them into ec_items)

    @author
    @creation-date
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse <bart.teeuwisse@7-sisters.com>
    @revision-date April 2002

} {
    shipping_method:optional
    usca_p:optional
    tax_exempt_p:optional
    shipping_gateway:optional
    quantity:array,optional
}

ec_redirect_to_https_if_possible_and_necessary

if {[info exists shipping_gateway] && [string equal $shipping_gateway "true"]} {
    if { ![info exists shipping_method] } {
	ad_return_error "A shipping method is required" "
	    <p>You forgot to select a shipping method.</p>
	    <p>Please back up your browser and pick a shipping service from the available services.</p>
	    <p>Should no shiping options be available for your shipping address then back up your browser
	      further and pick a different shipping address. Or contact <a href=\"mailto:[ec_system_owner]\">[ec_system_owner]</a> to arrange for special delivery.</p>"
    }
} else {
    if { ![info exists shipping_method] } {
	set shipping_method "standard"
    }
}

if {[info exists quantity]} {
    set arraynames [array names quantity]
    set fullarraynames [list]
    foreach arrayname $arraynames {
	set quantity.$arrayname $quantity($arrayname)
	lappend fullarraynames "quantity.$arrayname"
    }
    set return_url "process-order-quantity-shipping?[export_url_vars creditcard_id creditcard_number creditcard_type creditcard_expire_1 creditcard_expire_2 address_id shipping_method shipping_gateway tax_exempt_p]"
    ad_returnredirect "shopping-cart-quantities-change?[export_url_vars return_url]&[eval export_url_vars $fullarraynames]"
    return
}

# We need them to be logged in

set user_id [ad_verify_and_get_user_id]
if {$user_id == 0} {
    set form [ns_conn form]
    if { ![empty_string_p $form] } {
        set return_url "[ad_conn url]?[export_entire_form_as_url_vars]"
    } else {
        set return_url "[ad_conn url]"
    }
    ad_returnredirect "/register?[export_url_vars return_url]"
    return
}

# User sessions:
# 1. get user_session_id from cookie
# 2. If user has no session (i.e. user_session_id=0), attempt to set
#    it if it hasn't been attempted before
# 3. If it has been attempted before, give them message that we can't
#    do shopping carts without cookies

set user_session_id [ec_get_user_session_id]
ec_create_new_session_if_necessary [ec_export_entire_form_as_url_vars_maybe]
ec_log_user_as_user_id_for_this_session

# Make sure they have an in_basket order, otherwise they've probably
# gotten here by pushing Back, so return them to index.tcl

set order_id [db_string get_order_id "
    select order_id 
    from ec_orders
    where user_session_id = :user_session_id
    and order_state = 'in_basket'"  -default ""]

if { [empty_string_p $order_id] } {

    # Then they probably got here by pushing "Back", so just redirect
    # them to index.tcl

    ad_returnredirect index.tcl
    return
}

# Make sure there's something in their shopping cart, otherwise
# redirect them to their shopping cart which will tell them that it's
# empty.

if { [db_string get_count_cart "
    select count(*) 
    from ec_items
    where order_id = :order_id"] == 0 } {
    ad_returnredirect shopping-cart.tcl
    db_release_unused_handles
    return
}

# Make sure the order belongs to this user_id, otherwise they managed
# to skip past checkout.tcl, or they messed w/their user_session_id
# cookie

set order_owner [db_string get_order_owner "
    select user_id
    from ec_orders
    where order_id = :order_id"]

if { $order_owner != $user_id } {
    ad_returnredirect checkout.tcl
    return
}

# Make sure there is an address for this order, otherwise they've
# probably gotten here via url surgery, so redirect them to
# checkout.tcl

set address_id [db_string get_address_id "
    select shipping_address 
    from ec_orders
    where order_id = :order_id" -default ""]
if { [empty_string_p $address_id] } {

    # No shipping address is needed if the order only consists of
    # soft goods not requiring shipping.

    if {[db_0or1row shipping_avail "
	select p.no_shipping_avail_p, count (*)
	from ec_items i, ec_products p
	where i.product_id = p.product_id
	and p.no_shipping_avail_p = 'f' 
	and i.order_id = :order_id
	group by no_shipping_avail_p"]} {

	ad_returnredirect checkout.tcl
	return
    }
}

if { ![info exists tax_exempt_p] } {
    set tax_exempt_p "f"
}

# Everything is ok now; the user has a non-empty in_basket order and
# an address associated with it, so now update shipping method

# 1. Update the shipping method and tax status

if {[info exists shipping_gateway] && [string equal $shipping_gateway "true"]} {

    # A shipping gateway has been used. The shipping method contains
    # both the shipping service level and the associated total
    # charges.

    array set shipping_service_and_rate $shipping_method
    set shipping_method $shipping_service_and_rate(service_description)
    set order_shipping_cost $shipping_service_and_rate(total_charges)
}

db_dml update_shipping_method "
    update ec_orders
    set shipping_method = :shipping_method, tax_exempt_p = :tax_exempt_p
    where order_id = :order_id"

# 2. Put the prices into ec_items

# Set some things to use as arguments when setting prices

if { [ad_parameter -package_id [ec_id] UserClassApproveP ecommerce] } {
    set additional_user_class_restriction "and user_class_approved_p = 't'"
} else {
    set additional_user_class_restriction "and (user_class_approved_p is null or user_class_approved_p='t')"
}

set user_class_id_list [db_list get_list_user_classes "
    select user_class_id
    from ec_user_class_user_map
    where user_id = :user_id $additional_user_class_restriction"]

if {[info exists shipping_gateway] && [string equal $shipping_gateway "true"]} {

    # A shipping gateway has been used to calculate the total shipping
    # charges so there is no to calculate the charges per item.

    set default_shipping_per_item 0
    set weight_shipping_cost 0
    set add_exp_amount_per_item 0
    set add_exp_amount_by_weight 0
} else {
    if { $shipping_method != "pickup" && $shipping_method != "no shipping" } {
	db_1row get_shipping_per_item "
	    select default_shipping_per_item, weight_shipping_cost
	    from ec_admin_settings"
	db_1row get_exp_amt_peritem "
	    select add_exp_amount_per_item, add_exp_amount_by_weight 
	    from ec_admin_settings"
    } else {
	set default_shipping_per_item 0
	set weight_shipping_cost 0
	set add_exp_amount_per_item 0
	set add_exp_amount_by_weight 0
    }
}
set usps_abbrev [db_string get_usps_abbrev "
    select usps_abbrev 
    from ec_addresses 
    where address_id = :address_id" -default ""]
if { ![empty_string_p $usps_abbrev] && $tax_exempt_p == "f" } {
    if { [db_0or1row get_tax_rate "
	select tax_rate, shipping_p
	from ec_sales_tax_by_state
	where usps_abbrev = :usps_abbrev"]==0 } {
	set tax_rate 0
	set shipping_p f
    }
} else {
    set tax_rate 0
    set shipping_p f
}

# These will be updated as we loop through the items

set total_item_shipping_tax 0
set total_item_price_tax 0

db_foreach get_items_in_cart "
    select i.item_id, i.product_id, u.offer_code
    from ec_items i, (select * 
	from ec_user_session_offer_codes usoc 
	where usoc.user_session_id = :user_session_id) u
    where i.product_id=u.product_id(+)
    and i.order_id=:order_id" {

    set everything [ec_price_price_name_shipping_price_tax_shipping_tax_for_one_item $product_id $offer_code $item_id $order_id $user_class_id_list \
			$shipping_method $default_shipping_per_item $weight_shipping_cost $add_exp_amount_per_item $add_exp_amount_by_weight $tax_rate $shipping_p]
    set total_item_shipping_tax [expr $total_item_shipping_tax + [lindex $everything 4]]
    set total_item_price_tax [expr $total_item_price_tax + [lindex $everything 3]]
    set price_charged [lindex $everything 0]
    set price_name [lindex $everything 1]
    set shipping_charged [lindex $everything 2]
    set tax_charged [lindex $everything 3]
    set shipping_tax [lindex $everything 4]


    db_dml update_ec_items "
	update ec_items 
	set price_charged = round(:price_charged,2), price_name = :price_name, shipping_charged = round(:shipping_charged,2), 
	    price_tax_charged = round(:tax_charged,2), shipping_tax_charged = round(:shipping_tax,2) 
	where item_id = :item_id"
}

# 3. Determine base shipping cost & put it into ec_orders

if {![info exists shipping_gateway]} {
    if { $shipping_method != "pickup" && $shipping_method != "no shipping" } {
	set order_shipping_cost [db_string get_base_ship_cost "
	    select nvl(base_shipping_cost,0) 
	    from ec_admin_settings"]
    } else {
	set order_shipping_cost 0
    }

    # Add on the extra base cost for express shipping, if appropriate

    if { $shipping_method == "express" } {
	set add_exp_base_shipping_cost [db_string get_exp_base_cost "
	    select nvl(add_exp_base_shipping_cost,0) 
	    from ec_admin_settings"]
	set order_shipping_cost [expr $order_shipping_cost + $add_exp_base_shipping_cost]
    }
}

set tax_on_order_shipping_cost [db_string get_shipping_tax "
    select ec_tax(0,:order_shipping_cost,:order_id) 
    from dual"]

db_dml set_shipping_charges "
    update ec_orders 
    set shipping_charged = round(:order_shipping_cost,2), shipping_tax_charged = round(:tax_on_order_shipping_cost,2) 
    where order_id=:order_id"

db_release_unused_handles
ad_returnredirect billing.tcl
