ad_page_contract {
    @param usca_p User session begun or not

    @author
    @creation-date
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @revision-date April 2002
    
} {
    usca_p:optional
    product_id:optional
}
set logout_url "/register/logout?return_url=[ns_urlencode "[ec_url]"]"
# bottom links:
# 1) continue shopping (always)

# Case 1) Continue shopping
# Create the link now before the product_id gets overwritten when
# looping through the products in the cart.

set previous_product_id_p 0
set previous_product_id 0

if {[info exists product_id]} {
    set previous_product_id_p 1
    set previous_product_id $product_id
} 

# We don't need them to be logged in, but if they are they might get a
# lower price
set first_names ""
set last_name ""
set email ""

set user_id [ad_conn user_id]
if { $user_id != 0 } {
    ad_get_user_info
}

# user sessions:
# 1. get user_session_id from cookie
# 2. if user has no session (i.e. user_session_id=0), attempt to set it if it hasn't been
#    attempted before
# 3. if it has been attempted before, give them message that we can't do shopping carts
#    without cookies

set user_session_id [ec_get_user_session_id]
ec_create_new_session_if_necessary

# This is not being used anywhere
#set n_items_in_cart [db_string get_n_items "
#    select count(*) 
#    from ec_orders o, ec_items i
#    where o.order_id=i.order_id
#    and o.user_session_id=:user_session_id and o.order_state='in_basket'"]

set order_id [db_string get_order_id "
    select order_id
    from ec_orders
    where user_session_id = :user_session_id
    and order_state = 'in_basket'"  -default ""]

# calculate shipping charge options when not using shipping-gateway,
#  and then include the value with each option (for an informed choice)

# mainly from process-order-quantity-shipping.tcl

# set initial values for itemization loop
db_1row get_ec_admin_settings "
    select nvl(base_shipping_cost,0) as base_shipping_cost, 
    nvl(default_shipping_per_item,0) as default_shipping_per_item, 
    nvl(weight_shipping_cost,0) as weight_shipping_cost, 
    nvl(add_exp_base_shipping_cost,0) as add_exp_base_shipping_cost, 
    nvl(add_exp_amount_per_item,0) as add_exp_amount_per_item, 
    nvl(add_exp_amount_by_weight,0) as add_exp_amount_by_weight
    from ec_admin_settings"

set last_product_id 0
set product_counter 0
set total_price 0
set currency [parameter::get -parameter Currency]
set max_add_quantity_length [string length [parameter::get -parameter CartMaxToAdd]]
set offer_express_shipping_p [parameter::get -parameter ExpressShippingP]
set offer_pickup_option_p [parameter::get -parameter PickupP]
set paypal_business [parameter::get -parameter PayPalBusiness]
set paypal_standard_mode [parameter::get -parameter PayPalStandardMode]
set store_name [parameter::get -parameter SystemName]
set total_reg_shipping_price 0
set total_exp_shipping_price 0
set total_weight 0
set no_shipping_options "t"
set paypal_shipping_mode 1
# papal_shipping_mode should mirror no_shipping_options

# Check if a shipping gateway has been selected.
set shipping_gateway [parameter::get -parameter ShippingGateway]
set shipping_gateway_in_use [acs_sc_binding_exists_p ShippingGateway $shipping_gateway]
set shipping_address_id 0

set display_price_of_zero_as [parameter::get -parameter DisplayPriceOfZeroAs]
if { [string equal $display_price_of_zero_as "0.00"] } {
    set display_zero_as_special 0
} else {
    set display_zero_as_special 1
}
set includes_display_zero_as_items 0

if { $shipping_gateway_in_use} {
     #this section mainly from select-shipping.tcl

     # Replace the default ecommerce shipping calculations with the
     # charges from the shipping gateway, which contains
     # both the shipping service level and the associated total
     # charges. Requries zipcode and country, so
     # user needs to be logged in too.

    if { $user_id != 0 } { 
        set shipping_address_ids [db_list get_shipping_address_ids "
            select address_id
            from ec_addresses
            where user_id=:user_id
            and address_type = 'shipping'" ]

        if { [llength $shipping_address_ids] > 1 } {
        # the max valued id is most likely the newest id (no last used date field available)
            set shipping_address_id [ec_max_of_list $shipping_address_ids]
        } elseif { $shipping_address_ids > 0 } {
            set shipping_address_id $shipping_address_ids
        } else {
            set shipping_address_id 0
            set shipping_options "<table align=\"center\"><tr><td><p>We need your <a href=\"checkout\">shipping address</a> before we can quote a shipping price. You are able to review your order and any shipping charges before confirming an order.</p></td></tr></table>"
        }
        if { $shipping_address_id > 0 } {
            # we have a zipcode and country
    	    db_1row select_shipping_area "
    	        select country_code, zip_code 
    	        from ec_addresses
    	        where address_id = :shipping_address_id"
    
            # Calculate the total value of the shipment.
            set shipment_value 0
	}
    } else {
        # user_id == 0
        set shipping_options "<table align=\"center\"><tr><td><p>If you were logged in, we could show you any associated shipping charges</p></td></tr></table>"
    }
}


# adding some fields to handle calculating shipping prices
# p.no_shipping_avail_p, p.shipping, p.shipping_additional, p.weight
# basically collect shipping information for any items where ec_products.no_shipping_avail_p = 't'

db_multirow -extend { line_subtotal } in_cart get_products_in_cart "
      select p.product_name, p.one_line_description, p.no_shipping_avail_p, p.shipping, p.shipping_additonal, p.weight, p.product_id, p.sku, count(*) as quantity, u.offer_code, i.color_choice, i.size_choice, i.style_choice, '' as price 
      from ec_orders o
      join ec_items i on (o.order_id=i.order_id)
      join ec_products p on (i.product_id=p.product_id)
      left join (select product_id, offer_code 
	  from ec_user_session_offer_codes usoc 
	  where usoc.user_session_id=:user_session_id) u on (p.product_id=u.product_id)
      where o.user_session_id=:user_session_id 
      and o.order_state='in_basket'
      group by p.product_name, p.one_line_description, p.no_shipping_avail_p, p.shipping, p.shipping_additional, p.weight, p.product_id, u.offer_code, i.color_choice, i.size_choice, i.style_choice" {
          set line_subtotal "$quantity"
      }
# <input type=\"hidden\" name=\"item_name\" value=\"${store_name}\">  not used?
set paypal_checkout_button "<form action=\"https://www.paypal.com/cgi-bin/webscr\" method=\"post\">
<input type=\"hidden\" name=\"charset\" value=\"utf-8\">
<input type=\"hidden\" name=\"cmd\" value=\"_cart\">
<input type=\"hidden\" name=\"upload\" value=\"1\">
<input type=\"hidden\" name=\"_cart\" value=\"upload\">
<input type=\"hidden\" name=\"currency_code\" value=\"${currency}\">
<input type=\"hidden\" name=\"business\" value=\"${paypal_business}\">"

set line_items_count 0

for {set i 1} {$i <= [template::multirow size in_cart]} {incr i} {

    set product_name [template::multirow get in_cart $i product_name]
    set one_line_description [template::multirow get in_cart $i one_line_description]
    set product_id [template::multirow get in_cart $i product_id]
    set sku [template::multirow get in_cart $i sku]
    set no_shipping_avail_p [template::multirow get in_cart $i no_shipping_avail_p]
    set shipping [template::multirow get in_cart $i shipping]
    set shipping_additional [template::multirow get in_cart $i shipping_additional]
    set weight [template::multirow get in_cart $i weight]
    set quantity [template::multirow get in_cart $i quantity]
    set offer_code [template::multirow get in_cart $i offer_code]
    set color_choice [template::multirow get in_cart $i color_choice]
    set size_choice [template::multirow get in_cart $i size_choice]
    set style_choice [template::multirow get in_cart $i style_choice]


    set max_quantity_length [max $max_add_quantity_length [string length $quantity]]
    # Deletions are done by product_id, color_choice, size_choice,
    # style_choice, not by item_id because we want to delete the
    # entire quantity of that product.  Also print the price for a
    # product of the selected options and the aforementioned delete
    # option.

    set price_line [ec_price_line $product_id $user_id $offer_code]
    set delete_export_vars [export_url_vars product_id color_choice size_choice style_choice]

    # Too bad I have to do another call to get the price. That is
    # because ec_price_line returns canned html instead of the price.

    set lowest_price_and_price_name [ec_lowest_price_and_price_name_for_an_item $product_id $user_id $offer_code]
    set lowest_price [lindex $lowest_price_and_price_name 0]
    if { $lowest_price == 0 && $display_zero_as_special } {
        set includes_display_zero_as_items 1
    }

    # Calculate line subtotal for end users
    set line_subtotal [ec_pretty_price [expr $quantity * $lowest_price] $currency]
    template::multirow set in_cart $i line_subtotal $line_subtotal

    if { [string equal $no_shipping_avail_p "f"] && !$shipping_gateway_in_use} {
        # at least one thing is shippable, begin calculating ship value(s)
        set no_shipping_options "f"
        set paypal_shipping_mode 2
        # Calculate shipping for line item
        set first_instance 1
        set shipping_prices_for_first_line_item [ec_shipping_prices_for_one_item_by_rate $product_id $shipping $shipping_additional $default_shipping_per_item $weight $weight_shipping_cost $first_instance $add_exp_amount_per_item $add_exp_amount_by_weight]
        set total_reg_shipping_price [expr $total_reg_shipping_price + [lindex $shipping_prices_for_first_line_item 0]]
        set total_exp_shipping_price [expr $total_exp_shipping_price + [lindex $shipping_prices_for_first_line_item 1]]

        if { $quantity > 1 } {
            set first_instance 0
            set shipping_prices_for_more_line_items [ec_shipping_prices_for_one_item_by_rate $product_id $shipping $shipping_additional $default_shipping_per_item $weight $weight_shipping_cost $first_instance $add_exp_amount_per_item $add_exp_amount_by_weight]
            set total_reg_shipping_price [expr $total_reg_shipping_price + ( [lindex $shipping_prices_for_more_line_items 0] * ( $quantity - 1 ) ) ]
            set total_exp_shipping_price [expr $total_exp_shipping_price + ( [lindex $shipping_prices_for_more_line_items 1] * ( $quantity - 1 ) ) ]

        }
    } elseif { $shipping_gateway_in_use && $shipping_address_id > 0 && [string equal $no_shipping_avail_p "f"] } {
        set shipment_value [expr $shipment_value + [lindex [ec_lowest_price_and_price_name_for_an_item $product_id $user_id $offer_code] 0]]
    }

    # Add the price of the item to the total price

    set total_price [expr $total_price + ($quantity * $lowest_price)]
    incr product_counter $quantity

    # Add weight to order
    set total_weight [expr { $quantity * $weight + $total_weight } ]

    template::multirow set in_cart $i delete_export_vars $delete_export_vars
    template::multirow set in_cart $i price "[lindex $lowest_price_and_price_name 1]:&nbsp;&nbsp;[ec_pretty_price [lindex $lowest_price_and_price_name 0] $currency]"

    set line_items_count $i

    # calculate paypal line item
    set item_name [string range "${sku} ${product_name}, ${one_line_description}" 0 126]
    append paypal_checkout_button "
<input type=\"hidden\" name=\"item_name_${i}\" value=\"${item_name}\">
<input type=\"hidden\" name=\"item_number_${i}\" value=\"${sku}\">
<input type=\"hidden\" name=\"amount_${i}\" value=\"${lowest_price}\">
<input type=\"hidden\" name=\"quantity_${i}\" value=\"${quantity}\">"


}

set weight_unit_of_measure [parameter::get -parameter WeightUnits]


# Add adjust quantities line if there are products in the cart.
set pretty_total_price [ec_pretty_pure_price $total_price $currency]

# require shipping address

if { $shipping_gateway_in_use  && $shipping_address_id > 0} {

    set shipping_options "<table align=\"center\"><tr><td colspan=\"3\"
    	<p><b>Shipping method:</b></p></td></tr>"
    
    # Get the list of services and their charges
    
    set rates_and_services [lsort -index 1 -real \
    [acs_sc_call "ShippingGateway" "RatesAndServicesSelection" \
    [list "" "" "$country_code" "$zip_code" "$shipment_value" "$currency" "" "$weight_unit_of_measure"] "$shipping_gateway"]]
    
    # Present the available shipping services to the user
    
    foreach service $rates_and_services {
        array set rate_and_service $service
    	set total_charges $rate_and_service(total_charges)
    	set service_code $rate_and_service(service_code)
    	set service_description [acs_sc_call "ShippingGateway" "ServiceDescription" "$service_code" "$shipping_gateway"]
        set gateway_shipping_default_price $total_charges
    	append shipping_options "
            <tr><td>
                $service_description
              </td><td>
    	        [string map {USD $} $currency]
	      </td><td align=\"right\">
    	        $total_charges
    	    </td><tr>"
    }
    append shipping_options "</table>"        
}

if { !$shipping_gateway_in_use } {
    # Rate based shipping calculations
    # 3. Determine base shipping costs that are separate from items
 
    # set base shipping charges
    # reset standard to special shipping rate based on price
    set order_shipping_cost [expr { [ecds_base_shipping_price_from_order_value $total_price $base_shipping_cost] + $base_shipping_cost } ] 

    set shipping_method_standard $order_shipping_cost

    # Add on the extra base cost for express shipping
    set shipping_method_express [expr $order_shipping_cost + $add_exp_base_shipping_cost]

    # 4. set total costs for each shipping option
    set total_shipping_price_default $total_reg_shipping_price
    set total_reg_ship_price [format "%0.2f" [expr $total_reg_shipping_price + $shipping_method_standard]]
    set total_reg_shipping_price [ec_pretty_pure_price $total_reg_ship_price $currency "t"]
    set total_exp_ship_price [format "%0.2f" [expr $total_exp_shipping_price + $shipping_method_express]]
    set total_exp_shipping_price [ec_pretty_pure_price $total_exp_ship_price $currency "t"]
    set shipping_method_pickup [ec_pretty_pure_price 0 $currency "t"]
    set shipping_method_no_shipping 0

    # 5 prepare shipping options to present to user
    if { [string equal $no_shipping_options "f" ] } {
        # standard shipping is total_reg_shipping_price
        set shipping_options "Shipping is additional:"
        if { $offer_express_shipping_p } {
            # express shipping is total_exp_shipping_price
            set shipping_options "Shipping is additional, choices are:"
        }
        if { $offer_pickup_option_p } {
            # pickup instead of shipping is shipping_method_pickup
            set shipping_options "Shipping is additional, choices are:"
        }
    } else {
        set shipping_options "No shipping options available."

    }
}

# List the states that get charged tax. Although not 100% accurate
# as shipping might be taxed too this is better than nothing.

db_multirow -extend { pretty_tax } tax_entries tax_states "
 	select tax_rate, initcap(state_name) as state 
	from ec_sales_tax_by_state tax, us_states state 
	where state.abbrev = tax.usps_abbrev" {
		set pretty_tax "[format %0.2f [expr $tax_rate * 100]]%"
}

# calculate paypal cart totals, finish button html
if { $paypal_standard_mode == 1 } {
# 
append paypal_checkout_button "
<input type=\"hidden\" name=\"weight_cart\" value=\"${total_weight}\"> 
<input type=\"hidden\" name=\"weight_unit\" value=\"${weight_unit_of_measure}\">"
}

append paypal_checkout_button "
<input type=\"hidden\" name=\"custom\" value=\"user_session_id ${user_session_id}\">
<input type=\"hidden\" name=\"invoice\" value=\"order_id ${order_id}\">
<input type=\"hidden\" name=\"tax_cart\" value=\"0\">
<input type=\"hidden\" name=\"no_shipping\" value=\"${paypal_shipping_mode}\">
<input type=\"hidden\" name=\"return\" value=\"[ec_secure_location][ec_url]paypal-thankyou\">
<input type=\"hidden\" name=\"cancel_return\" value=\"[ec_secure_location][ec_url]shopping-cart\">
<input type=\"hidden\" name=\"rm\" value=\"2\">
<input type=\"hidden\" name=\"paymentaction\" value=\"authorization\">"


if { $paypal_shipping_mode == 2 && $paypal_standard_mode == 3 } {
    set ii [expr { $line_items_count + 1 } ]
    set paypal_checkout_button_stand "${paypal_checkout_button}
<input type=\"hidden\" name=\"item_number_${ii}\" value=\"ship-hand\">
<input type=\"hidden\" name=\"item_name_${ii}\" value=\"Shipping and Handling, standard/CIF\">
<input type=\"hidden\" name=\"amount_${ii}\" value=\"${total_reg_ship_price}\">
<input type=\"hidden\" name=\"quantity_${ii}\" value=\"1\">
Standard&nbsp;shipping&nbsp;<input type=\"submit\" value=\"PayPal\" title=\"Standard shipping\" alt=\"Check out with PayPal. The safer, easier way to pay.\">&nbsp;checkout
</form>"
    set paypal_checkout_button_expr "${paypal_checkout_button}
<input type=\"hidden\" name=\"item_number_${ii}\" value=\"ship-hand\">
<input type=\"hidden\" name=\"item_name_${ii}\" value=\"Shipping and Handling, express/CIF\">
<input type=\"hidden\" name=\"amount_${ii}\" value=\"${total_exp_ship_price}\">
<input type=\"hidden\" name=\"quantity_${ii}\" value=\"1\">
Express&nbsp;shipping&nbsp;<input type=\"submit\" value=\"PayPal\" title=\"Express shipping\" alt=\"Check out with PayPal. The safer, easier way to pay.\">&nbsp;checkout
</form>"
} else {
    append paypal_checkout_button "
Checkout with <input type=\"submit\" value=\"PayPal\" title=\"Check out with PayPal. The safer, easier way to pay.\" alt=\"PayPal.\">. A safe, easy way to pay.
</form>"

}
if { $paypal_standard_mode > 0 && $paypal_standard_mode < 3} {
    set no_shipping_options "t"
}

# src="http://www.paypal.com/en_US/i/btn/btn_xpressCheckout.gif" alt="Check out with PayPal. The safer, easier way to pay." 

# bottom links:
# 1) continue shopping (always and already created)
# 2) log in (if they're not logged in)
# 3) retrieve a saved cart (if they are logged in and they have a saved cart)
# 4) save their cart (if their cart is not empty)

if { $user_id == 0 } {

    # Case 2) the user is not logged in.
    set return_url [ns_urlencode "[ec_url]"]

} else {
    # Case 3) Retrieve saved carts
    set saved_carts_p [db_string check_for_saved_carts "
	select 1 
	from dual 
	where exists (
	    select 1 
	    from ec_orders 
	    where user_id=:user_id 
	    and order_state='in_basket' 
	    and saved_p='t')" -default ""]
}


set title "Shopping Cart"
set context [list $title]
set ec_system_owner [ec_system_owner]
db_release_unused_handles
ad_return_template
