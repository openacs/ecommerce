# /www/ecommerce/credit-card-correction-2.tcl
ad_page_contract {
 1. do the normal url/cookie surgery checks
 2. insert credit card data into ec_creditcards
 3. update orders to use this credit card
 4. redirect to finalize-order.tcl to process this info

    @param creditcard_number Their credit card number
    @param creditcard_type The brand of credit card
    @param creditcard_expire_1 The month of expiration
    @param creditcard_expire_2 The year of expiration
    @param billing_zip_code The zip code of the billing address

    @author
    @creation-date
    @cvs-id credit-card-correction-2.tcl,v 3.3.2.8 2000/08/18 21:46:32 stevenp Exp
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    creditcard_number:notnull
    creditcard_type:notnull
    creditcard_expire_1:notnull
    creditcard_expire_2:notnull
    billing_zip_code:notnull
}

# Doubleclick problem:
# There is a small but finite amount of time between the time that the user runs
# this script and the time that their order goes into the 'confirmed' state.
# During this time, it is possible for the user to submit their credit card info
# twice, thereby adding rows to ec_creditcards.
# However, no order will be updated after it's confirmed, so this credit card info
# will be unreferenced by any order and we can delete it with a cron job.

# first do the basic error checking
# also get rid of spaces and dashes in the credit card number
if { [info exists creditcard_number] } {
    # get rid of spaces and dashes
    regsub -all -- "-" $creditcard_number "" creditcard_number
    regsub -all " " $creditcard_number "" creditcard_number
}

set exception_count 0
set exception_text ""

if { [regexp {[^0-9]} $creditcard_number] } {
    # I've already removed spaces and dashes, so only numbers should remain
    incr exception_count
    append exception_text "<li> Your credit card number contains invalid characters."
}

# make sure the credit card type is right & that it has the right number
# of digits
set additional_count_and_text [ec_creditcard_precheck $creditcard_number $creditcard_type]

set exception_count [expr $exception_count + [lindex $additional_count_and_text 0]]
append exception_text [lindex $additional_count_and_text 1]

if { $exception_count > 0 } {
    ad_return_complaint $exception_count $exception_text
    return
}

# then do all the normal checks to make sure nobody is doing url
# or cookie surgery to get here

# we need them to be logged in
set user_id [ad_verify_and_get_user_id]

if {$user_id == 0} {
    
    set return_url "[ad_conn url]?[export_url_vars creditcard_number creditcard_type creditcard_expire_1 creditcard_expire_2 billing_zip_code]"

    ad_returnredirect "/register?[export_url_vars return_url]"
    return
}

# make sure they have an in_basket order
# unlike previous pages, if they don't have an in_basket order
# it may be because they tried to execute this code twice and
# the order is already in the confirmed state
# In this case, they should be redirected to the thank you
# page for the most recently confirmed order, if one exists,
# otherwise redirect them to index.tcl

set user_session_id [ec_get_user_session_id]

set order_id [db_string get_order_id_from_basket "select order_id from ec_orders where user_session_id=:user_session_id and order_state='in_basket'" -default ""]

if { [empty_string_p $order_id] } {

    # find their most recently confirmed order
    set most_recently_confirmed_order [db_string get_mrc_order "select order_id from ec_orders where user_id=:user_id and confirmed_date is not null and order_id=(select max(o2.order_id) from ec_orders o2 where o2.user_id=:user_id and o2.confirmed_date is not null)" -default ""]
    if { [empty_string_p $most_recently_confirmed_order] } {
	ad_returnredirect index
    } else {
	ad_returnredirect thank-you
    }
    return
}

# make sure there's something in their shopping cart, otherwise
# redirect them to their shopping cart which will tell them
# that it's empty.

if { [db_string get_ec_item_count "select count(*) from ec_items where order_id=:order_id"] == 0 } {
    ad_returnredirect shopping-cart
    return
}

# make sure the order belongs to this user_id, otherwise they managed to skip past checkout.tcl, or
# they messed w/their user_session_id cookie
set order_owner [db_string get_order_owner "select user_id from ec_orders where order_id=:order_id"]

if { $order_owner != $user_id } {
    ad_returnredirect checkout
    return
}

# done with all the checks!

# do some inserts
set creditcard_id [db_string set_creditcard_id_from_seq "select ec_creditcard_id_sequence.nextval from dual"]

db_transaction {
set cc_fmt "[string range $creditcard_number [expr [string length $creditcard_number] -4] [expr [string length $creditcard_number] -1]]"
set expiry "$creditcard_expire_1/$creditcard_expire_2"

db_dml insert_new_creditcard "insert into ec_creditcards
(creditcard_id, user_id, creditcard_number, creditcard_last_four, creditcard_type, creditcard_expire, billing_zip_code)
values
(:creditcard_id, :user_id, :creditcard_number,:cc_fmt , :creditcard_type,:expiry,:billing_zip_code)
"

# make sure order is still in the 'in_basket' state while doing the
# insert because it could have been confirmed in the (small) time
# it took to get from "set order_id ..." to here
# if not, no harm done; no rows will be updated

db_dml update_order_cc_info "update ec_orders set creditcard_id=:creditcard_id where order_id=:order_id and order_state='in_basket'"

}
db_release_unused_handles
ad_returnredirect finalize-order
