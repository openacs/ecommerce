ad_page_contract {

    1. do the normal url/cookie surgery checks
    2. insert credit card data into ec_creditcards
    3. update orders to use this credit card
    4. redirect to finalize-order.tcl to process this info

    @param creditcard_number Their credit card number
    @param creditcard_type The brand of credit card
    @param creditcard_expire_1 The month of expiration
    @param creditcard_expire_2 The year of expiration

    @author
    @creation-date
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @revision-date April 2002

} {
    address_id:notnull
    creditcard_number:notnull
    creditcard_type:notnull
    creditcard_expire_1:notnull
    creditcard_expire_2:notnull
    {card_code ""}
}

# Doubleclick problem: There is a small but finite amount of time
# between the time that the user runs this script and the time that
# their order goes into the 'confirmed' state.  During this time, it
# is possible for the user to submit their credit card info twice,
# thereby adding rows to ec_creditcards.  However, no order will be
# updated after it's confirmed, so this credit card info will be
# unreferenced by any order and we can delete it with a cron job.

# First do the basic error checking.  Also get rid of spaces and
# dashes in the credit card number

if { [info exists creditcard_number] } {

    # Get rid of spaces and dashes

    regsub -all -- "-" $creditcard_number "" creditcard_number
    regsub -all -- " " $creditcard_number "" creditcard_number
}

set exception_count 0
set exception_text ""

if { [regexp {[^0-9]} $creditcard_number] } {

    # I've already removed spaces and dashes, so only numbers should
    # remain

    incr exception_count
    append exception_text "<li> Your credit card number contains invalid characters.</li>"
}

# Make sure the credit card type is right & that it has the right
# number of digits

set additional_count_and_text [ec_creditcard_precheck $creditcard_number $creditcard_type $card_code]
set exception_count [expr $exception_count + [lindex $additional_count_and_text 0]]
append exception_text [lindex $additional_count_and_text 1]
if { $exception_count > 0 } {
    ad_return_complaint $exception_count $exception_text
    ad_script_abort
}

# Then do all the normal checks to make sure nobody is doing url or
# cookie surgery to get here

# We need them to be logged in

set user_id [ad_conn user_id]
if {$user_id == 0} {
    set return_url "[ad_conn url]?[export_url_vars creditcard_number creditcard_type creditcard_expire_1 creditcard_expire_2].</li>"
    ad_returnredirect "/register?[export_url_vars return_url]"
    ad_script_abort
}

# Make sure they have an in_basket order unlike previous pages, if
# they don't have an in_basket order it may be because they tried to
# execute this code twice and the order is already in the confirmed
# state In this case, they should be redirected to the thank you page
# for the most recently confirmed order, if one exists, otherwise
# redirect them to index.tcl

set user_session_id [ec_get_user_session_id]
set order_id [db_string get_order_id_from_basket "
    select order_id 
    from ec_orders 
    where user_session_id = :user_session_id
    and order_state = 'in_basket'" -default ""]

if { [empty_string_p $order_id] } {

    # Find their most recently confirmed order

    set most_recently_confirmed_order [db_string get_mrc_order "
	select order_id
	from ec_orders
	where user_id = :user_id
	and confirmed_date is not null
	and order_id = (select max(o2.order_id)
			from ec_orders o2 
			where o2.user_id = :user_id 
			and o2.confirmed_date is not null)" -default ""]
    if { [empty_string_p $most_recently_confirmed_order] } {
	rp_internal_redirect index
    } else {
	rp_internal_redirect thank-you
    }
    ad_script_abort
}

# Make sure there's something in their shopping cart, otherwise
# redirect them to their shopping cart which will tell them that it's
# empty.

if { [db_string get_ec_item_count "
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

# Done with all the checks!

# Do some inserts

set creditcard_id [db_nextval ec_creditcard_id_sequence]
db_transaction {
    set cc_fmt "[string range $creditcard_number [expr [string length $creditcard_number] -4] [expr [string length $creditcard_number] -1]]"
    set expiry "$creditcard_expire_1/$creditcard_expire_2"

    db_dml insert_new_creditcard "
	insert into ec_creditcards
	(creditcard_id, user_id, creditcard_number, creditcard_last_four, creditcard_type, creditcard_expire, billing_address)
	values
	(:creditcard_id, :user_id, :creditcard_number,:cc_fmt , :creditcard_type, :expiry, :address_id)"

    # Make sure order is still in the 'in_basket' state while doing
    # the insert because it could have been confirmed in the (small)
    # time it took to get from "set order_id ..." to here if not, no
    # harm done; no rows will be updated

    db_dml update_order_cc_info "
	update ec_orders
	set creditcard_id = :creditcard_id
	where order_id = :order_id
	and order_state = 'in_basket'"

}
db_release_unused_handles
rp_form_put card_code $card_code
rp_internal_redirect finalize-order
