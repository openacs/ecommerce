ad_page_contract {

    Begins processing a payment from a customer, using either a credit
    card on file or a card they entered in payment.tcl (which is the only
    way to get to this script).

    <p>If there's anything in creditcard_number, that will override
    the selection of a past credit card.

    @param creditcard_id
    @param creditcard_number
    @param creditcard_type
    @param creditcard_expire_1
    @param creditcard_expire_2
    @param billing_address_id

    @author original author unknown (eveander@arsdigita.com?)
    @author hbrock@arsdigita.com
    @creation-date
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse <bart.teeuwisse@7-sisters.com>
    @revision-date April 2002

} {
    creditcard_id:optional
    creditcard_number:optional
    creditcard_type:optional
    creditcard_expire_1:optional
    creditcard_expire_2:optional
    billing_address_id:optional
    usca_p:optional
}

ec_redirect_to_https_if_possible_and_necessary

if { [info exists creditcard_number] } {

    # get rid of spaces and dashes

    regsub -all -- "-" $creditcard_number "" creditcard_number
    regsub -all " " $creditcard_number "" creditcard_number
}

# We need them to be logged in

set user_id [ad_verify_and_get_user_id]
if {$user_id == 0} {
    set return_url "[ad_conn url]"
    ad_returnredirect "/register?[export_url_vars return_url]"
    ad_script_abort
}

# User sessions:
# 1. get user_session_id from cookie
# 2. if user has no session (i.e. user_session_id=0), attempt to set it if it hasn't been
#    attempted before
# 3. if it has been attempted before, give them message that we can't do shopping carts
#    without cookies

set user_session_id [ec_get_user_session_id]
ec_create_new_session_if_necessary [ec_export_entire_form_as_url_vars_maybe]
ec_log_user_as_user_id_for_this_session

# Make sure they have an in_basket order, otherwise they've probably
# gotten here by pushing Back, so return them to index.tcl

set order_id [db_string  get_order_id "
    select order_id 
    from ec_orders 
    where user_session_id=:user_session_id 
    and order_state='in_basket'" -default ""]
if { [empty_string_p $order_id] } {

    # Then they probably got here by pushing "Back", so just redirect
    # them to index.tcl

    rp_internal_redirect index
    ad_script_abort
}

# Make sure there's something in their shopping cart, otherwise
# redirect them to their shopping cart which will tell them
# that it's empty.

if { [db_string get_shopping_cart_no "
    select count(*) 
    from ec_items 
    where order_id=:order_id"] == 0 } {
    rp_internal_redirect shopping-cart
    ad_script_abort
}

# Make sure the order belongs to this user_id, otherwise they managed
# to skip past checkout.tcl, or they messed w/their user_session_id
# cookie

set order_owner [db_string get_order_owner "
    select user_id 
    from ec_orders 
    where order_id=:order_id"]
if { $order_owner != $user_id } {
    rp_internal_redirect checkout
    ad_script_abort
}

# Make sure there is an address for this order, otherwise they've
# probably gotten here via url surgery, so redirect them to
# checkout.tcl

set address_id [db_string get_address_id "
     select shipping_address 
     from ec_orders 
     where order_id=:order_id" -default ""]
if { [empty_string_p $address_id] } {

    # No shipping address is needed if the order only consists of soft
    # goods not requiring shipping.

    if {[db_0or1row shipping_avail "
	select p.no_shipping_avail_p, count (*)
	from ec_items i, ec_products p
	where i.product_id = p.product_id
	and p.no_shipping_avail_p = 'f' 
	and i.order_id = :order_id
	group by no_shipping_avail_p"]} {
	ad_returnredirect [ec_securelink [ec_url]checkout]
        ad_script_abort
    }
}

# Make sure there is a shipping method for this order, otherwise
# they've probably gotten here via url surgery, so redirect them to
# checkout-2.tcl

set shipping_method [db_string get_shipping_method "
    select shipping_method 
    from ec_orders 
    where order_id=:order_id"]
if { [empty_string_p $shipping_method] } {
    rp_internal_redirect checkout-2
    ad_script_abort
}

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

if { $gift_certificate_covers_cost_p == "f" } {
    
    if { ![info exists creditcard_id] || ([info exists creditcard_number] && ![empty_string_p $creditcard_number]) } {
	if { ![info exists creditcard_number] || [empty_string_p $creditcard_number] } {

	    # Then they haven't selected a previous credit card nor
	    # have they entered new credit card info

	    ad_return_complaint 1 "<li> You forgot to specify which credit card you'd like to use."
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
		append exception_text "<li> Your credit card number contains invalid characters."
	    }
	    	    
	    if { ![info exists creditcard_type] || [empty_string_p $creditcard_type] } {
		incr exception_count
		append exception_text "<li> You forgot to enter your credit card type."
	    }
	    
	    # make sure the credit card type is right & that it has
	    # the right number of digits

	    set additional_count_and_text [ec_creditcard_precheck $creditcard_number $creditcard_type]
	    set exception_count [expr $exception_count + [lindex $additional_count_and_text 0]]
	    append exception_text [lindex $additional_count_and_text 1]
	    
	    if { ![info exists creditcard_expire_1] || [empty_string_p $creditcard_expire_1] || ![info exists creditcard_expire_2] || [empty_string_p $creditcard_expire_2] } {
		incr exception_count
		append exception_text "<li> Please enter your full credit card expiration date (month and year)"
	    }
	    
	    if { $exception_count > 0 } {
		ad_return_complaint $exception_count $exception_text
                ad_script_abort
	    }

	    # A valid credit card number has been provided and thus a
	    # billing address must exist.

	    if {![info exists billing_address_id] || ([info exists billing_address_id] && [empty_string_p $billing_address_id])} {
		ad_return_complaint 1 "<li> You forgot to provide your billing address.</li>"
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
	    ad_return_complaint 1 "<li> You forgot to provide your billing address.</li>"
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

    if { $gift_certificate_covers_cost_p == "f" } {
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

db_release_unused_handles
rp_internal_redirect checkout-3
