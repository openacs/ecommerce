ad_page_contract {

    This generates a custom single order fulfillment page 
    with options to interface with the sophisticated multi address fulfillment 
    processing, when enough address history exists to make it worthwhile
    Essentially combines /ecommerce/www/checkout* address* select-shipping* billing* payment*

    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse <bart.teeuwisse@7-sisters.com>
    @author combined by Torben Brosten <torben@kappacorp.com>
    @creation-date March 2004

    @param usca_p:optional User session if started

} {
    usca_p:optional
}

# security checks
# following from checkout.tcl

ec_redirect_to_https_if_possible_and_necessary

# Make sure they have an in_basket order, otherwise they've probably
# gotten here by pushing Back, so return them to index.tcl

set user_id [ad_conn user_id]
set user_session_id [ec_get_user_session_id]
ec_create_new_session_if_necessary

ec_log_user_as_user_id_for_this_session

set order_id [db_string  get_order_id "
    select order_id
    from ec_orders
    where user_session_id = :user_session_id
    and order_state='in_basket'" -default "" ]

if { [empty_string_p $order_id] } {

    # Then they probably got here by pushing "Back", so just redirect
    # them to index.tcl

    rp_internal_redirect index
    ad_script_abort
} else {
    db_dml update_ec_order_set_uid "
	update ec_orders 
	set user_id = :user_id
	where order_id = :order_id"
}

    # end security check

    # useful references declared: order_id, user_id, user_session_id 

    # Retrieve the user name, use as default
    
    db_0or1row get_names "
        select first_names, last_name
      	from cc_users
        where user_id=:user_id"

    # is there an existing shipping address?

    if { ![info exists address_id] } {
       set address_id [db_string  get_address_id "
	select shipping_address 
	from ec_orders 
	where order_id=:order_id" -default ""]
    set shipping_address_id $address_id
    }

# set initial conditions needed to build and process this form

    set form_action [ec_securelink [ec_url]checkout-one-form-2]    
    set hidden_vars ""
    set show_item_detail_p "f"

    set gateway_shipping_default_price 0

    set gift_certificate_covers_whole_order 0
    set gift_certificate_covers_part_of_order 0

    set address_type "billing"
    set billing_address_exists 0
    set more_addresses_available "f"

    set currency [ad_parameter -package_id [ec_id] Currency ecommerce]
    set tax_exempt_status [ad_parameter -package_id [ec_id] OfferTaxExemptStatusP ecommerce 0]
    set tax_exempt_options ""
    if { $tax_exempt_status == "t" } {
        append tax_exempt_options "
        <p><b><li>Is your organization tax exempt? (If so, we will ask you to
          provide us with an exemption certificate.)</b>
        <input type=\"radio\" name=\"tax_exempt_p\" value=\"t\">Yes<br>
        <input type=\"radio\" name=\"tax_exempt_p\" value=\"f\" checked>No</p>"
    }

    # prepare the cart contents for display
    # following mainly from ec_order_summary_for_customer

    set items_ul ""
    set order_total 0
    set last_product_id 0

    db_foreach order_details_select "
	select i.price_name, i.price_charged, i.color_choice, i.size_choice, i.style_choice,
	    p.product_name, p.one_line_description, p.product_id, count(*) as quantity 
	from ec_items i, ec_products p
	where i.order_id = :order_id
	and i.product_id = p.product_id
	group by p.product_name, p.one_line_description, p.product_id, i.price_name, i.price_charged, i.color_choice, i.size_choice, i.style_choice" {
	    if {$product_id != $last_product_id} {
	        set lowest_price [lindex [ec_lowest_price_and_price_name_for_an_item $product_id $user_id] 0]
	    }
            set option_list [list]
	    if { ![empty_string_p $color_choice] } {
	        lappend option_list "Color: $color_choice"
	    }
	    if { ![empty_string_p $size_choice] } {
	        lappend option_list "Size: $size_choice"
	    }
	    if { ![empty_string_p $style_choice] } {
	        lappend option_list "Style: $style_choice"
	    }
	    set options [join $option_list ", "]
	    if { ![empty_string_p $options] } {
	        set options "$options; "
	    }

	    append items_ul "<li>Quantity $quantity: $product_name; $options$price_name [ec_pretty_price $lowest_price $currency]"
	    if { $show_item_detail_p == "t" } {
	        append items_ul "<br>
	        [ec_shipment_summary_sub $product_id $color_choice $size_choice $style_choice $price_charged $price_name $order_id]"
	    }
	    append items_ul "</li>"

	    set order_total [expr $order_total + $quantity * $lowest_price]

    }
    set order_total_price_pre_gift_certificate $order_total    


    # Check if the order requires shipping
    
    if {[db_0or1row shipping_avail "
        select p.no_shipping_avail_p
        from ec_items i, ec_products p
        where i.product_id = p.product_id
        and p.no_shipping_avail_p = 'f' 
        and i.order_id = :order_id
        group by no_shipping_avail_p"]} {
    
        set shipping_required "t"

    }  else {
        set shipping_required "f"
    }


    # calculate shipping options

# prepare shipping method choices (shipping rates determined previously)
# some of this from ec_price_price_name_shipping_price_tax_shipping_tax_for_one_item
# and from ec_shipping_price_for_one_item
# and select-shipping.tcl  


    # Check if a shipping gateway has been selected.
    set shipping_gateway [ad_parameter ShippingGateway ecommerce]
    set shipping_gateway_in_use [acs_sc_binding_exists_p ShippingGateway $shipping_gateway]

# below was:  if info exists no_shipping_avail_p && string equal $no_shipping_avail_p "f"
if { [exists_and_equal shipping_required "t"] } {

        if { $shipping_gateway_in_use} {

            if { $address_id != 0 } { 

                # Replace the default ecommerce shipping calculations with the
                # charges from the shipping gateway, which contains
                # both the shipping service level and the associated total
                # charges. Requries zipcode and country.
    
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
    	        <p><b>Shipping method:</b></p>
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
    	            set service_description [acs_sc_call "ShippingGateway" "ServiceDescription" "$service_code" "$shipping_gateway"]
                    append shipping_options "
    		    <tr>
    		      <td>
    		        <input type=\"radio\" name=\"shipping_method\" value=\"[list service_description  $service_description total_charges $total_charges]\""
     	            if {$cheapest_service} {
     		        append shipping_options " checked"
     		        set cheapest_service false
                        set gateway_shipping_default_price $total_charges
     	            }
    	            append shipping_options ">
    		    $service_description 
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
            } else { set shipping_options "<table><tr><td><p>We need your shipping address before we can quote a shipping price. You will be able to review your order and shipping charge before confirming the order.</p></td></tr></table>"
            }
        } else {
            # calculate shipping charge options when not using shipping-gateway,
            #  and then include the value with each option (for an informed choice)

            # mainly from process-order-quantity-shipping.tcl
            set total_reg_shipping_price 0
            set total_exp_shipping_price 0
            set last_product_id 0

            db_1row get_ec_admin_settings "
	    select nvl(base_shipping_cost,0) as base_shipping_cost, 
            nvl(default_shipping_per_item,0) as default_shipping_per_item, 
            nvl(weight_shipping_cost,0) as weight_shipping_cost, 
            nvl(add_exp_base_shipping_cost,0) as add_exp_base_shipping_cost, 
            nvl(add_exp_amount_per_item,0) as add_exp_amount_per_item, 
            nvl(add_exp_amount_by_weight,0) as add_exp_amount_by_weight
	    from ec_admin_settings"

            db_foreach get_items_in_cart "
            select i.item_id, i.product_id, u.offer_code
            from ec_items i, (select * 
            from ec_user_session_offer_codes usoc 
            where usoc.user_session_id = :user_session_id) u
            where i.product_id=u.product_id(+)
            and i.order_id=:order_id
            order by i.product_id" {
                # ordering by i.product_id so loop can identify first instance of a quantity
                if { $product_id == $last_product_id } {
                    set first_instance 0
                } else {
                    set first_instance 1
                    db_1row get_shipping_info "
	            select shipping, shipping_additional, weight 
	            from ec_products 
	            where product_id=:product_id"
                }
		set shipping_prices_for_one_item [ec_shipping_prices_for_one_item_by_rate $product_id $shipping $shipping_additional $default_shipping_per_item $weight $weight_shipping_cost $first_instance $add_exp_amount_per_item $add_exp_amount_by_weight]

                set total_reg_shipping_price [expr $total_reg_shipping_price + [lindex $shipping_prices_for_one_item 0]]
                set total_exp_shipping_price [expr $total_exp_shipping_price + [lindex $shipping_prices_for_one_item 1]]
                set last_product_id $product_id
            }


# 3. Determine base shipping costs that are separate from items
 
            # set base shipping charge

            set order_shipping_cost $base_shipping_cost

            set shipping_method_standard $order_shipping_cost

            # Add on the extra base cost for express shipping

            set shipping_method_express [expr $order_shipping_cost + $add_exp_base_shipping_cost]

# 4. set total costs for each shipping option
            set total_shipping_price_default $total_reg_shipping_price
	    set total_reg_shipping_price [ec_pretty_pure_price [expr $total_reg_shipping_price + $shipping_method_standard] $currency "t"]
	    set total_exp_shipping_price [ec_pretty_pure_price [expr $total_exp_shipping_price + $shipping_method_express] $currency "t"]
            set shipping_method_pickup [ec_pretty_pure_price 0 $currency "t"]
            set shipping_method_no_shipping 0

# 5 prepare shipping options to present to user

            set shipping_options "
    	        <p><b>Shipping method:</b></p>
    	        <p><input type=\"radio\" name=\"shipping_method\" value=\"standard\" checked>Standard Shipping ($total_reg_shipping_price)<br>"

    	    if { [ad_parameter -package_id [ec_id] ExpressShippingP ecommerce] } {
    	        append shipping_options "
    	        <input type=\"radio\" name=\"shipping_method\" value=\"express\">Express ($total_exp_shipping_price)<br>"
    	    }
    	    if { [ad_parameter -package_id [ec_id] PickupP ecommerce] } {
    	        append shipping_options "
    	        <input type=\"radio\" name=\"shipping_method\" value=\"pickup\">Pickup ($shipping_method_pickup)"
    	    }
            append shipping_options "</p>"
        }
        # bracket above ends if gateway not used
    } else {
        # shipping not available or required
        set total_shipping_price_default 0
    }


# we want to present the most recent billing address, if there is one

    set billing_address_ids [db_list get_billing_address_ids "
        select address_id
        from ec_addresses
        where user_id=:user_id
        and address_type = 'billing'" ]

    #  $more_billing_addresses_available can be used in the adp to notify the user
    #  to choose one of their other billing addresses, if any
    if { [llength $billing_address_ids] > 1 } {
        # the max valued id is most likely the newest id (no date_last_modified field available)
        set billing_address_id [ec_max_of_list $billing_address_ids]
        set more_billing_addresses_available "t"
    } else {
        set more_billing_addresses_available "f"
        if { $billing_address_ids > 0 } {
            set billing_address_id $billing_address_ids
        } else {
            # we assume that no valid address_id is ever 0
            set billing_address_id 0
        }
    }

    # retrieve a saved address
    set address_id $billing_address_id
    if { [info exists address_id] } {
	set billing_address_exists [db_0or1row select_address "
    	select attn, line1, line2, city, usps_abbrev, zip_code, phone, country_code, full_state_name, phone_time 
    	from ec_addresses 
    	where address_id=:address_id"]
    }
    if {$billing_address_exists == 1} {
        set bill_to_attn $attn
        # split attn for separate first_names, last_name processing, delimiter is triple space
        # separate first_names, last_name is required for some payment gateway validation systems (such as EZIC)
        set name_delim [string first "   " $attn]
        if {$name_delim < 0 } {
            set name_delim 0
        }
        set bill_to_first_names [string trim [string range $attn 0 $name_delim]]
        set bill_to_last_name [string range $attn [expr $name_delim + 3 ] end]

        set bill_to_line1 $line1
        set bill_to_line2 $line2
        set bill_to_city $city
        set bill_to_usps_abbrev $usps_abbrev
        set bill_to_zip_code $zip_code
        set bill_to_phone $phone
        set bill_to_country_code [ec_country_widget $country_code "bill_to_country_code"]
        set bill_to_full_state_name $full_state_name
        set bill_to_phone_time $phone_time
        set bill_to_state_widget [ec_state_widget $usps_abbrev "bill_to_usps_abbrev"]
    } else {
        set billing_address_id 0 
        # no previous billing address, set defaults
        set bill_to_first_names [value_if_exists first_names]
        set bill_to_last_name [value_if_exists last_name]

        set bill_to_line1 ""
        set bill_to_line2 ""
        set bill_to_city ""
        set bill_to_usps_abbrev ""
        set bill_to_zip_code ""
        set bill_to_phone ""
        set bill_to_country_code [ec_country_widget "US" "bill_to_country_code"]
        set bill_to_full_state_name ""
        set bill_to_phone_time ""
        set bill_to_state_widget [ec_state_widget "" "bill_to_usps_abbrev"]
    }

if { [exists_and_equal shipping_required "t"] } {
# prepare shipping address
    
    set address_type "shipping"

    set shipping_address_exists 0
    
    # we want to present the most recent shipping address, if there is one
    # alternately, we can always start with a blank shipping address for all cases,
    # if we want to bias users to use their billing addresses. 
    set shipping_address_ids [db_list get_shipping_address_ids "
        select address_id
`        from ec_addresses
        where user_id=:user_id
        and address_type = 'shipping'" ]

    #  $more_shipping_addresses_available can be used to notify the user
    #  to choose one of their other shipping addresses, if any
    #  ("previous addresses shipped to" link?) 
    if { [llength $shipping_address_ids] > 1 } {
        set  more_shipping_addresses_available "t"
        # the max valued id is most likely the newest id (no last used date field available)
        set shipping_address_id [ec_max_of_list $shipping_address_ids]
    } else {
        set more_shipping_addresses_available "f"
        if { $shipping_address_ids > 0 } {
            set shipping_address_id $shipping_address_ids
        } else {
            set shipping_address_id 0
	}
    }
    if {$more_billing_addresses_available == "t" || $more_shipping_addresses_available == "t" } {
        set more_addresses_available "t"
    } else {
        set more_addresses_available "f"
    }
    # retrieve a saved address
    set address_id $shipping_address_id
    if { [info exists address_id] } {
	set shipping_address_exists [db_0or1row select_address "
    	select attn, line1, line2, city, usps_abbrev, zip_code, phone, country_code, full_state_name, phone_time 
    	from ec_addresses 
    	where address_id=:address_id"]
    }
    if {$shipping_address_exists == 1} {
        set ship_to_attn $attn
        # split attn for separate first_names, last_name processing, delimiter is triple space
        # separate first_names, last_name is required for some payment gateway validation systems (such as EZIC)
        # in some cases, shipping address can be used as the default for billing address
        set name_delim [string first "   " $attn]
        if {$name_delim < 0 } {
            set name_delim 0
        }
        set ship_to_first_names [string trim [string range $attn 0 $name_delim]]
        set ship_to_last_name [string range $attn [expr $name_delim + 3 ] end]

        set ship_to_line1 $line1
        set ship_to_line2 $line2
        set ship_to_city $city
        set ship_to_usps_abbrev $usps_abbrev
        set ship_to_zip_code $zip_code
        set ship_to_phone $phone
        set ship_to_country_code [ec_country_widget $country_code "ship_to_country_code"]
        set ship_to_full_state_name $full_state_name
        set ship_to_phone_time $phone_time
        set ship_to_state_widget [ec_state_widget $usps_abbrev "ship_to_usps_abbrev"]
    } else {
        set shipping_address_id 0
        # no previous shipping address, set defaults
        set ship_to_first_names ""
        set ship_to_last_name ""

        set ship_to_line1 ""
        set ship_to_line2 ""
        set ship_to_city ""
        set ship_to_usps_abbrev ""
        set ship_to_zip_code ""
        set ship_to_phone ""
        set ship_to_country_code [ec_country_widget "US" "ship_to_country_code"]
        set ship_to_full_state_name ""
        set ship_to_phone_time ""
        set ship_to_state_widget [ec_state_widget "" "ship_to_usps_abbrev"]
    }
    # next bracket ends prepare shipping
}

# prepare payment information

    # ec_order_cost returns price + shipping + tax - gift_certificate BUT
    # no gift certificates have been applied to in_basket orders, so this
    # just returns price + shipping + tax
    
    db_1row get_order_cost "
                select ec_order_cost(:order_id) as otppgc,
                ec_gift_certificate_balance(:user_id) as user_gift_certificate_balance
           from dual"

    # Had to do this because the variable name below is too long for
    # Oracle.  It should be changed, but not in this upgrade
    # hbrock@arsdigita.com

    set order_total_price_pre_gift_certificate $otppgc
    unset otppgc
    
# ec_order_cost does not work here, except maybe in special circumstances,
# where it might actually be more accurate than the alternate calculation. 

    if { $order_total_price_pre_gift_certificate == 0 } {
        # building order_total_price_pre_gift_certificate from an above query
        # shipping value uses default from previous calcs on this page
	if { $shipping_gateway_in_use == 1 } {
            # there might not be an address available yet, so regional taxes are in flux still
	    set order_total_price_pre_gift_certificate [expr $order_total + $gateway_shipping_default_price]
        } else {
            # note: this does not include taxes for total value of order
            set order_total_price_pre_gift_certificate [expr $order_total + $total_shipping_price_default]
        }
    }

    # these variable names help clarify usage for non-programmers editing the ADP
    # templates:
    
    set customer_can_use_old_credit_cards 0
    
    set show_creditcard_form_p "t"

    if { $user_gift_certificate_balance >= $order_total_price_pre_gift_certificate } {
        set gift_certificate_covers_whole_order 1
        set show_creditcard_form_p "f"
    } elseif { $user_gift_certificate_balance > 0 } {
        set gift_certificate_covers_part_of_order 1
        set certificate_amount [ec_pretty_pure_price $user_gift_certificate_balance]
    }
    
    if { $show_creditcard_form_p == "t" } {
        set customer_can_use_old_credit_cards [ad_parameter -package_id [ec_id] SaveCreditCardDataP ecommerce]
    
        # See if the administrator lets customers reuse their credit cards
    
        if { $customer_can_use_old_credit_cards } {
    
            # Then see if we have any credit cards on file for this user
    	    # for this shipping address only (for security purposes)
    
    	    set to_print_before_creditcards "
    	    <table>
    	      <tr>
    		<td></td>
    		<td><b>Card Type</b></td>
    		<td><b>Last 4 Digits</b></td>
    		<td><b>Expires</b></td>
    	      </tr>"
    	    set card_counter 0
    	    set old_cards_to_choose_from ""
    
    	    db_foreach get_creditcards_onfile "
    	    select c.creditcard_id, c.creditcard_type, c.creditcard_last_four, c.creditcard_expire
    	    from ec_creditcards c
    	    where c.user_id=:user_id
    	    and c.creditcard_number is not null
    	    and c.failed_p='f'
    	    and 0 < (select count(*) from ec_orders o where o.creditcard_id = c.creditcard_id)
    	    order by c.creditcard_id desc" {
    	    
    	        if { $card_counter == 0 } {
    		    append old_cards_to_choose_from $to_print_before_creditcards
    	        }
    	        append old_cards_to_choose_from "
    		<tr>
    		  <td><input type=\"radio\" name=\"creditcard_id\" value=\"$creditcard_id\""
    	        if { $card_counter == 0 } {
    		    append old_cards_to_choose_from " checked"
    	        }
    	        append old_cards_to_choose_from ">
    		</td>
    		<td>[ec_pretty_creditcard_type $creditcard_type]</td>
    		<td align=\"center\">$creditcard_last_four</td>
    		<td align=\"right\">$creditcard_expire</td>
    		</tr>"
                incr card_counter
    	    } if_no_rows {
    	        set customer_can_use_old_credit_cards 0
    	    }
        }
        
        set ec_creditcard_widget [ec_creditcard_widget]
        set ec_expires_widget "[ec_creditcard_expire_1_widget] [ec_creditcard_expire_2_widget]"
    
        # If customer_can_use_old_credit_cards is 0, we don't have to
        # worry about what's in old_cards_to_choose_from because it won't
        # get printed in the template anyway.
    
        append old_cards_to_choose_from "</table>"
    }
    
    set gift_certificate_p [ad_parameter -package_id [ec_id] SellGiftCertificatesP ecommerce]

# quoting is default behavior for openacs 5.x +
#    set bill_to_first_names [ad_quotehtml $bill_to_first_names]
#    set bill_to_last_name [ad_quotehtml $bill_to_last_name]

#    set bill_to_line1 [ad_quotehtml $bill_to_line1]
#    set bill_to_line2 [ad_quotehtml $bill_to_line2]
#    set bill_to_city [ad_quotehtml $bill_to_city]
#    set bill_to_usps_abbrev [ad_quotehtml $bill_to_usps_abbrev]
#    set bill_to_zip_code [ad_quotehtml $bill_to_zip_code]
#    set bill_to_phone [ad_quotehtml $bill_to_phone]
#    cannot quote bill_to_country_code [ad_quotehtml $country_code]
#    set bill_to_full_state_name [ad_quotehtml $bill_to_full_state_name]
#    set bill_to_phone_time [ad_quotehtml $bill_to_phone_time]
#    cannot quote bill_to_state_widget [ad_quotehtml $state_widget]

if { [exists_and_equal shipping_required "t"] } {
#    set ship_to_first_names [ad_quotehtml $ship_to_first_names]
#    set ship_to_last_name [ad_quotehtml $ship_to_last_name]

#    set ship_to_line1 [ad_quotehtml $ship_to_line1]
#    set ship_to_line2 [ad_quotehtml $ship_to_line2]
#    set ship_to_city [ad_quotehtml $ship_to_city]
#    set ship_to_usps_abbrev [ad_quotehtml $ship_to_usps_abbrev]
#    set ship_to_zip_code [ad_quotehtml $ship_to_zip_code]
#    set ship_to_phone [ad_quotehtml $ship_to_phone]
#    cannot quote ship_to_country_code [ad_quotehtml $ship_to_country_code]
#    set ship_to_full_state_name [ad_quotehtml $ship_to_full_state_name]
#    set ship_to_phone_time [ad_quotehtml $ship_to_phone_time]
#    cannot quote ship_to_state_widget [ad_quotehtml $ship_to_state_widget]
}
    append hidden_vars [export_form_vars billing_address_id shipping_address_id]
set title "Completing Your Order"
set context [list $title]
db_release_unused_handles
