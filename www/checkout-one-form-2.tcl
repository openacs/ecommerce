ad_page_contract {

    @param billing_address_id
    @param bill_to_first_names
    @param bill_to_last_name
    @param bill_to_phone
    @param bill_to_phone_time:optional
    @param bill_to_line1:notnull
    @param bill_to_line2
    @param bill_to_city
    @param bill_to_usps_abbrev:optional
    @param bill_to_full_state_name:optional
    @param bill_to_zip_code:optional
    @param bill_to_country_code

    @param claim_check for gift certificate
    @param creditcard_expire_1:optional
    @param creditcard_expire_2:optional
    @param creditcard_number:optional
    @param creditcard_type:optional
    @param creditcard_id:optional
    @param customer_can_use_old_credit_cards:optional
    @param old_cards_to_choose_from:optional

    @param certificate_amount:optional
    @param order_total_price_pre_gift_certificate:optional

    @param shipping_address_id:optional,naturalnum
    @param ship_to_first_names:optional
    @param ship_to_last_name:optional
    @param ship_to_phone:optional
    @param ship_to_phone_time:optional
    @param ship_to_line1:optional
    @param ship_to_line2:optional
    @param ship_to_city:optional
    @param ship_to_usps_abbrev:optional
    @param ship_to_full_state_name:optional
    @param ship_to_zip_code:optional
    @param ship_to_country_code:optional

    @param shipping_method:optional
    @param shipping_options:optional

    @param tax_exempt_p:optional
    @param usca_p:optional
    @param value_currency_code:optional
    @param card_code:optional

    @author
    @creation-date April 2002
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse <bart.teeuwisse@7-sisters.com>
    @author combined by Torben Brosten <torben@kappacorp.com>
    @creation-date March 2004

} {

    billing_address_id:optional,naturalnum
    bill_to_first_names
    bill_to_last_name
    bill_to_phone
    bill_to_phone_time:optional
    bill_to_line1:notnull
    bill_to_line2:optional
    bill_to_city
    bill_to_usps_abbrev:optional
    bill_to_full_state_name:optional
    bill_to_zip_code:optional
    bill_to_country_code

    claim_check:optional
    creditcard_expire_1:optional
    creditcard_expire_2:optional
    creditcard_number:optional
    creditcard_type:optional
    creditcard_id:optional
    customer_can_use_old_credit_cards:optional
    old_cards_to_choose_from:optional

    certificate_amount:optional
    order_total_price_pre_gift_certificate:optional

    shipping_address_id:optional,naturalnum
    ship_to_first_names:optional
    ship_to_last_name:optional
    ship_to_phone:optional
    ship_to_phone_time:optional
    ship_to_line1:optional
    ship_to_line2:optional
    ship_to_city:optional
    ship_to_usps_abbrev:optional
    ship_to_full_state_name:optional
    ship_to_zip_code:optional
    ship_to_country_code:optional

    shipping_method:optional
    shipping_options:optional

    tax_exempt_p:optional
    usca_p:optional
    value_currency_code:optional
    {card_code ""}
}

# We need them to be logged in

set user_id [ad_conn user_id]
if {$user_id == 0} {
    ns_log Notice "checkout-one-form-2.tcl,ref(137): user_id is 0 which should never happen, redirecting user."
    rp_form_put return_url "[ad_conn url]?[export_entire_form_as_url_vars]" 
    rp_internal_redirect "/register"
    ad_script_abort
}

# eventually evolve this so checks come first, then ad_return_complaints 
# ie show complaints after all input has been checked, to provide thorough feedback to user


if {![info exists bill_to_country_code]} {
    ad_return_complaint 1 [list [list bill_to_country_code "billing country"]]
    ad_script_abort
} elseif { [string equal $bill_to_country_code "US"] } {
    set possible_exception_list [list [list bill_to_first_names "billing first name"] [list bill_to_last_name "billing last name"] [list bill_to_line1 "billing street address"] [list bill_to_city "billing city"] [list bill_to_usps_abbrev "billing state"] [list bill_to_zip_code "billing zip code"] [list bill_to_phone "billing telephone number"]]
} else {
    set possible_exception_list [list [list bill_to_first_names "billing first name"] [list bill_to_last_name "billing last name"] [list bill_to_line1 "billing street address"] [list bill_to_city "billing city"] [list bill_to_country_code "billing country"] [list bill_to_phone "billing telephone number"]]
}

set exception_count 0
set exception_text ""

foreach possible_exception $possible_exception_list {
    if { ![info exists [lindex $possible_exception 0]] || [empty_string_p [set [lindex $possible_exception 0]]] } {
    incr exception_count
    append exception_text "<li>A [lindex $possible_exception 1] is required.</li>"
    }
}

if { $exception_count > 0 } {
    ns_log Notice "checkout-one-form-2.tcl,ref(127): $exception_count form input exception(s) for user $user_id"
    ad_return_complaint $exception_count $exception_text
    ad_script_abort
}


# Make sure they have an in_basket order unless they are ordering a
# gift certificate, otherwise they've probably gotten here by pushing
# Back, so return them to index.tcl

set user_session_id [ec_get_user_session_id]
set order_id [db_string get_order_id "
    select order_id 
    from ec_orders 
    where user_session_id = :user_session_id 
    and order_state = 'in_basket'" -default ""]

if { [empty_string_p $order_id] } {

    # They probably got here by pushing "Back", so just redirect
    # them to index.tcl
    ns_log Notice "checkout-one-form-2.tcl,ref(157): order_id is empty, redirecting user $user_id."
    rp_internal_redirect index
    ad_script_abort
}
ns_log Notice "checkout-one-form-2.tcl,ref(161): processing user_id: $user_id, order_id: $order_id"

# start processing the info from checkout-one-form


# check addresses against existing addresses, if any (bill_to_address_id_exists_p, ship_to_address_id_exists_p
# if there's any difference, then assume it's a new address, otherwise, use existing address_id

# for billing address

regsub -all { +} $bill_to_first_names " " bill_to_first_names
regsub -all { +} $bill_to_last_name " " bill_to_last_name
set bill_to_attn "[string trim $bill_to_first_names]   [string trim $bill_to_last_name]"

if { [value_if_exists billing_address_id] > 0} {

    # This is an existing address that might have been edited

    set address_id $billing_address_id

    # retrieve a saved address 
    set billing_address_exists [db_0or1row select_address "
        select attn, line1, line2, city, usps_abbrev, zip_code, phone, country_code, full_state_name, phone_time 
        from ec_addresses 
        where address_id=:address_id
        and user_id=:user_id"]
    
    if { $billing_address_exists == 0 } {
    # They probably got here by playing with the billing_address_id number
    # have them login again, to make sure they should even have access to current session

        ec_user_session_logout      
        ns_log Notice "checkout-one-form-2.tcl,ref(193): billing_address_id mismatch. logging out user $user_id."   
    }

    # compare billing address with address from db

    set combined_billing_address "${bill_to_attn}${bill_to_line1}${bill_to_line2}${bill_to_city}${bill_to_usps_abbrev}${bill_to_zip_code}${bill_to_phone}${bill_to_country_code}${bill_to_full_state_name}${bill_to_phone_time}"
    set combined_address "${attn}${line1}${line2}${city}${usps_abbrev}${zip_code}${phone}${country_code}${full_state_name}${phone_time}"
    regsub -all { } $combined_billing_address "" combined_billing_address
    regsub -all { } $combined_address "" combined_address
    if { [string equal $combined_billing_address $combined_address] != 1 } {
        set new_address "t"
    } else {
        # billing addresses same
        set new_address "f"
    }
} else {
    # no billing address id exists
    set new_address "t"
}

if { [string equal $new_address "t"] } {
    # This is a new address which requires a new address_id.
    set address_type "billing"
    set attn $bill_to_attn
    set line1 $bill_to_line1 
    set line2 $bill_to_line2 
    set city $bill_to_city 
    if {[info exists bill_to_usps_abbrev]} {
        set usps_abbrev $bill_to_usps_abbrev
    } else {
        # billing address, bill_to_usps_abbrev does not exist
        set usps_abbrev ""
    }
    if {[info exists bill_to_zip_code]} {
        set zip_code [string range $bill_to_zip_code 0 9]
    } else {
        set zip_code ""
    }
    set phone $bill_to_phone
    set country_code $bill_to_country_code
    set full_state_name $bill_to_full_state_name
    set phone_time $bill_to_phone_time
    set address_id [db_nextval ec_address_id_sequence]
    db_transaction {
    db_dml insert_new_address "
    insert into ec_addresses
        (address_id, user_id, address_type, attn, line1, line2, city, usps_abbrev, full_state_name, zip_code, country_code, phone, phone_time)
        values
        (:address_id, :user_id, :address_type, :attn,:line1,:line2,:city,:usps_abbrev,:full_state_name,:zip_code,:country_code,:phone,:phone_time)"
    }
    # ec_orders does not track billing address directly, so won't insert an address_id to it.
}

set billing_address_id $address_id

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

set combined_shipping_address ""

if { [string equal $shipping_required "t"] } {
# when ship_to_address info is empty, fill it with the bill_to address info and set ship_to_address_id_exists_p false

    # get the shipping_address_id used by checkout-one-form.tcl
    set shipping_address_ids [db_list get_shipping_address_ids "
        select address_id
`        from ec_addresses
        where user_id=:user_id
        and address_type = 'shipping'" ]
    set shipping_address_id [ec_max_of_list $shipping_address_ids]


    # Update the shipping address of the order
    regsub -all { +} $ship_to_first_names " " ship_to_first_names
    regsub -all { +} $ship_to_last_name " " ship_to_last_name
    set ship_to_attn "[string trim $ship_to_first_names]   [string trim $ship_to_last_name]"

    # lets combine the shipping address, for comparison to any existing default, and to see if there is anything to work with
    set combined_shipping_address "${ship_to_attn}${ship_to_line1}${ship_to_line2}${ship_to_city}${ship_to_usps_abbrev}${ship_to_zip_code}${ship_to_phone}${ship_to_country_code}${ship_to_full_state_name}${ship_to_phone_time}"
    regsub -all { } $combined_shipping_address "" combined_shipping_address

    # check addresses against existing addresses, if any (bill_to_address_id_exists_p, ship_to_address_id_exists_p
    # if there's any difference, then assume it's a new address, otherwise, use existing address_id

    if { $shipping_address_id > 0 } {

        # Shipping address was presented to user, the existing address info might have been edited
        set address_id $shipping_address_id

        # retrieve a saved address 
        set shipping_address_exists [db_0or1row select_address "
        select attn, line1, line2, city, usps_abbrev, zip_code, phone, country_code, full_state_name, phone_time 
        from ec_addresses 
        where address_id=:address_id
        and user_id=:user_id"]
    
        if { $shipping_address_exists == 0 } {
        # They probably got here by playing with the shipping_address_id number
        # have them login again, to make sure they should even have access to current session
            ns_log Notice "checkout-one-form-2.tcl,ref(305). shipping_address_id is 0 which should never happen. logging out user $user_id"
            ec_user_session_logout         
        }

        # compare shipping address with address from db

        set combined_address "${attn}${line1}${line2}${city}${usps_abbrev}${zip_code}${phone}${country_code}${full_state_name}${phone_time}"
        regsub -all { } $combined_address "" combined_address

        if { [string equal $combined_shipping_address $combined_address] != 1 } {
            set new_address "t"
        } else {
           # addresses are the same
           set new_address "f"
        }

    } else {
        # no previous shipping address, so address must be new
        set new_address "t"

    }

    if { [string equal $new_address "t"] } {

        if { [string length $combined_shipping_address] < 15 } {
            # shipping address must be blank, replace with billing address

            set ship_to_attn $bill_to_attn
            set ship_to_line1 $bill_to_line1
            set ship_to_line2 $bill_to_line2
            set ship_to_city $bill_to_city
            if {[info exists bill_to_usps_abbrev]} {
                set ship_to_usps_abbrev $bill_to_usps_abbrev
            } else {
                set ship_to_usps_abbrev ""
            }
            if {[info exists bill_to_zip_code]} {
                set ship_to_zip_code $bill_to_zip_code
            } else {
                set ship_to_zip_code ""
            }
            set ship_to_phone $bill_to_phone
            set ship_to_country_code $bill_to_country_code
            set ship_to_full_state_name $bill_to_full_state_name
            set ship_to_phone_time $bill_to_phone_time
        }

        # This is a new address which requires an address_id.
        set address_type "shipping"
        set attn $ship_to_attn
        set line1 $ship_to_line1 
        set line2 $ship_to_line2 
        set city $ship_to_city 
        set usps_abbrev $ship_to_usps_abbrev
        set zip_code [string range $ship_to_zip_code 0 9]
        set phone $ship_to_phone
        set country_code $ship_to_country_code
        set full_state_name $ship_to_full_state_name
        set phone_time $ship_to_phone_time
        set address_id [db_nextval ec_address_id_sequence]
        db_transaction {
        db_dml insert_new_address "
            insert into ec_addresses
            (address_id, user_id, address_type, attn, line1, line2, city, usps_abbrev, full_state_name, zip_code, country_code, phone, phone_time)
            values
            (:address_id, :user_id, :address_type, :attn,:line1,:line2,:city,:usps_abbrev,:full_state_name,:zip_code,:country_code,:phone,:phone_time)"
        }
    }

    # Update the shipping address of the order

    db_dml set_shipping_on_order "
    update ec_orders 
    set shipping_address = :address_id 
    where order_id = :order_id"
}

# See if there's a gift certificate with a claim check

if {[info exists claim_check] && ![empty_string_p $claim_check]} {
    set gift_certificate_id [db_string get_gc_id "
    select gift_certificate_id 
    from ec_gift_certificates 
    where claim_check=:claim_check" -default ""]
    if { [empty_string_p $gift_certificate_id] } {
        ad_return_complaint 1 "
    <p>The claim check you have entered is invalid.  Please re-check it.</p>
    <p>The claim check is case sensitive; enter it exactly as shown on your gift certificate.</p>"
        set prob_details "
    Incorrect gift certificate claim check entered at [ad_conn url].
    Claim check entered: $claim_check by user ID: $user_id.
    They may have just made a typo but if this happens repeatedly from the same IP address ([ns_conn peeraddr]) you may wish to look into this."
        db_dml insert_error_failed_gc_claim "
    insert into ec_problems_log
        (problem_id, problem_date, problem_details)
        values
        (ec_problem_id_sequence.nextval, sysdate,:prob_details )"
        ad_script_abort
    }

    # There is a gift certificate with that claim check;
    # now check whether it's already been claimed
    # and, if so, whether it was claimed by this user

    db_1row get_gc_user_id "
    select user_id as gift_certificate_user_id, amount 
    from ec_gift_certificates 
    where gift_certificate_id = :gift_certificate_id"

    if { [empty_string_p $gift_certificate_user_id ] } {

        # Then no one has claimed it, so go ahead and assign it to them

        db_dml update_ec_cert_set_user "
    update ec_gift_certificates 
    set user_id=:user_id, claimed_date = sysdate 
    where gift_certificate_id = :gift_certificate_id"
        set title "Gift Certificate Claimed"
        set certificate_added_p "true"
    } else {

        # It's already been claimed. See if it was claimed by a different
        # user and, if so, record the problem

        if { $user_id != $gift_certificate_user_id } {

        set prob_details "
        User ID $user_id tried to claim gift certificate $gift_certificate_id at [ad_conn url], but it had already been claimed by User ID $gift_certificate_id."
    
        db_dml insert_other_claim_prob "
        insert into ec_problems_log
        (problem_id, problem_date, gift_certificate_id, problem_details)
        values
        (ec_problem_id_sequence.nextval, sysdate, :gift_certificate_id, :prob_details)"
        }

        set title "Gift Certificate Already Claimed"
        set certificate_added_p "false"
    }
}


# following mainly from process-order-quanity-shipping.tcl

# update shipping method

# 1. Update the shipping method and tax status

if {[info exists shipping_gateway] && [string equal $shipping_gateway "true"]} {

    # A shipping gateway has been used. The shipping method contains
    # both the shipping service level and the associated total
    # charges.

    array set shipping_service_and_rate $shipping_method
    set shipping_method $shipping_service_and_rate(service_description)
    set order_shipping_cost $shipping_service_and_rate(total_charges)
}

if {![info exists tax_exempt_p]} {
    set tax_exempt_p "f"
}
if {[empty_string_p $tax_exempt_p]} {
    set tax_exempt_p "f"
}

if {![info exists shipping_method]} {
    # shipping method does not exist
    set shipping_method ""
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
    if {![info exists shipping_method]} {
        # shipping method does not exist
        set shipping_method ""
    }

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
if { ![empty_string_p $usps_abbrev] && [string equal $tax_exempt_p "f"] } {
    if { [db_0or1row get_tax_rate "
    select tax_rate, shipping_p
    from ec_sales_tax_by_state
    where usps_abbrev = :usps_abbrev"] == 0 } {
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
set bom_price 0

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

    set bom_price [expr { $bom_price + $price_charged } ]

    db_dml update_ec_items "
    update ec_items 
    set price_charged = round(:price_charged,2), price_name = :price_name, shipping_charged = round(:shipping_charged,2), 
    price_tax_charged = round(:tax_charged,2), shipping_tax_charged = round(:shipping_tax,2) 
    where item_id = :item_id"
ns_log Notice "checkout-one-form-2.tcl ref571 total_item_price_tax $total_item_price_tax, bom_price $bom_price"
}

ns_log Notice "checkout-one-form-2.tcl ref572 total_item_price_tax $total_item_price_tax, bom_price $bom_price"

# 3. Determine base shipping cost & put it into ec_orders

if {![info exists shipping_gateway]} {

    if {![info exists shipping_method]} {
        # shipping_method does not exist
        set shipping_method ""
    }

    if { $shipping_method != "pickup" && $shipping_method != "no shipping" } {
        set order_shipping_cost [db_string get_base_ship_cost "
    select nvl(base_shipping_cost,0) 
    from ec_admin_settings"]
        # adding cost based shipping fee
        set order_shipping_cost [expr { [ecds_base_shipping_price_from_order_value $bom_price ] + $order_shipping_cost } ] 
 ns_log Notice "checkout-one-form-2.tcl(ref587) total_item_price_tax $total_item_price_tax, order_shipping_cost $order_shipping_cost"
    } else {
        set order_shipping_cost 0
    }

    # Add on the extra base cost for express shipping, if appropriate

    if { [string equal $shipping_method "express"] } {
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

# following mainly from process-payment.tcl

# Now do error checking; It is required that either
# (a) their gift_certificate_balance covers the total order price, or
# (b) they've selected a previous credit card (and creditcard_number is null,
#     otherwise we assume they want to use a new credit card), or
# (c) *all* of the credit card information for a new card has been filled in

# we only want price and shipping from this (to determine whether
# gift_certificate_balance covers cost)

set price_shipping_gift_certificate_and_tax [ec_price_shipping_gift_certificate_and_tax_in_an_order $order_id]
set order_total_price_pre_gift_certificate [expr [lindex $price_shipping_gift_certificate_and_tax 0] + [lindex $price_shipping_gift_certificate_and_tax 1]]
set gift_certificate_balance [db_string get_gc_balance "
    select ec_gift_certificate_balance(:user_id) 
    from dual"]
if { $gift_certificate_balance >= $order_total_price_pre_gift_certificate } {
    set gift_certificate_covers_cost_p "t"
} else {
    set gift_certificate_covers_cost_p "f"
}

if { [info exists creditcard_number] } {

    # get rid of spaces and dashes

    regsub -all -- "-" $creditcard_number "" creditcard_number
    regsub -all " " $creditcard_number "" creditcard_number
}

if { [string equal $gift_certificate_covers_cost_p "f"] } {
    
    if { ![info exists creditcard_id] || ([info exists creditcard_number] && ![empty_string_p $creditcard_number]) } {
    if { ![info exists creditcard_number] || [empty_string_p $creditcard_number] } {

        # Then they haven't selected a previous credit card nor
        # have they entered new credit card info

        ad_return_complaint 1 "<li> A credit card is required to complete this order."
            ad_script_abort
    } else {

        # Then they are using a new credit card and we just have
        # to check that they got it all right
        
        set exception_count 0
        set exception_text ""
        
        if { [regexp {[^0-9]} $creditcard_number] } {

        # I've already removed spaces and dashes, so only
        # numbers should remain

        incr exception_count
        append exception_text "<li> The credit card number contains invalid characters."
        }
                
        if { ![info exists creditcard_type] || [empty_string_p $creditcard_type] } {
        incr exception_count
        append exception_text "<li> The credit card type is unknown."
        }
        
        # make sure the credit card type is right & that it has
        # the right number of digits

        set additional_count_and_text [ec_creditcard_precheck $creditcard_number $creditcard_type $card_code]
        set exception_count [expr $exception_count + [lindex $additional_count_and_text 0]]
        append exception_text [lindex $additional_count_and_text 1]
        
        if { ![info exists creditcard_expire_1] || [empty_string_p $creditcard_expire_1] || ![info exists creditcard_expire_2] || [empty_string_p $creditcard_expire_2] } {
        incr exception_count
        append exception_text "<li> A full credit card expiration date (month and year) is required."
        }
        
        if { $exception_count > 0 } {
                ns_log Notice "checkout-one-form-2.tcl,ref(683): $exception_count form input exception(s) for user $user_id"
        ad_return_complaint $exception_count $exception_text
                ad_script_abort
        }

        # A valid credit card number has been provided and thus a
        # billing address must exist.

        if {![info exists billing_address_id] || ([info exists billing_address_id] && [empty_string_p $billing_address_id])} {
        ad_return_complaint 1 "<li> A billing address is required.</li>"
                ad_script_abort
        }
    }
    } else {

    # they're using an old credit card, although we should make
    # sure they didn't submit to us someone else's creditcard_id
    # or a blank creditcard_id

    if { [empty_string_p $creditcard_id] } {

        # Probably form surgery

        rp_internal_redirect checkout-2
            ad_script_abort
    }

    set creditcard_owner [db_string get_cc_owner "
        select user_id 
        from ec_creditcards 
        where creditcard_id=:creditcard_id" -default ""]
    if { $user_id != $creditcard_owner } {

        # Probably form surgery

        rp_internal_redirect checkout-2
            ad_script_abort
    }

    # A valid credit card number has been provided and thus a
    # billing address must exist.

    if {![info exists billing_address_id] || ([info exists billing_address_id] && [empty_string_p $billing_address_id])} {
        ad_return_complaint 1 "<li> A billing address is required.</li>"
            ad_script_abort
    }

    }
}

# Everything is ok now; the user has a non-empty in_basket order and
# an address associated with it, so now insert credit card info if
# needed

db_transaction {
    # If gift_certificate doesn't cover cost, either insert or update
    # credit card
    if { [string equal $gift_certificate_covers_cost_p "f"] } {
    if { ![info exists creditcard_number] || [empty_string_p $creditcard_number] } {

        # Using pre-existing credit card

        db_dml use_existing_cc_for_order "
        update ec_orders 
        set creditcard_id=:creditcard_id 
        where order_id=:order_id"
        db_dml update_cc_address "
        update ec_creditcards
        set billing_address = :billing_address_id
        where creditcard_id = :creditcard_id"
    } else {

        # Using new credit card

        set creditcard_id [db_nextval ec_creditcard_id_sequence]
        set cc_no [string range $creditcard_number [expr [string length $creditcard_number] -4] [expr [string length $creditcard_number] -1]]
        set expiry "$creditcard_expire_1/$creditcard_expire_2"
        db_dml insert_new_cc "
            insert into ec_creditcards
            (creditcard_id, user_id, creditcard_number, creditcard_last_four, creditcard_type, creditcard_expire, billing_address)
            values
            (:creditcard_id, :user_id, :creditcard_number, :cc_no , :creditcard_type, :expiry, :billing_address_id)"
        db_dml update_order_set_cc "
            update ec_orders 
                set creditcard_id=:creditcard_id 
                where order_id=:order_id"
    }
    } else {

    # Make creditcard_id be null (which it might not be if this isn't
    # their first time along this path)

    db_dml set_null_cc_in_order "
         update ec_orders
        set creditcard_id=null 
        where order_id=:order_id"
    }
}
set context [list $title]
db_release_unused_handles
rp_form_put referer checkout-one-form-2
rp_internal_redirect checkout-3.tcl
