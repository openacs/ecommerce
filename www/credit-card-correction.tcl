# /www/ecommerce/credit-card-correction.tcl
ad_page_contract {
    Gives them a chance to correct the information for a credit card that CyberCash rejected
    @param usca_p User session started or not

    @author
    @creation-date
    @cvs-id credit-card-correction.tcl,v 3.3.2.9 2000/08/18 21:46:32 stevenp Exp
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    usca_p:optional
}

# The order that we're trying to reauthorize is the 'in_basket' order for their user_session_id
# because orders are put back into the 'in_basket' state when their authorization fails

# We can't just update ec_creditcards with the new info because there might be a previous
# order which points to this credit card, so insert a new row into ec_creditcards.
# Obvious mistypes (wrong # of digits, etc.) will be weeded out before this point anyway,
# so the ec_creditcards table shouldn't get too huge.

# do all the normal url/cookie surgery checks
# except don't bother with the ones unneccessary for security (like "did they put in an address for
# this order?") because finalize-order.tcl (which they'll be going through to authorize their credit
# card) will take care of those.

# we need them to be logged in
set user_id [ad_verify_and_get_user_id]

if {$user_id == 0} {
    
    set return_url "[ad_conn url]"

    ad_returnredirect "/register?[export_url_vars return_url]"
    return
}

# make sure they have an in_basket order

set user_session_id [ec_get_user_session_id]


ec_create_new_session_if_necessary
# type1

ec_log_user_as_user_id_for_this_session

set order_id [db_string  get_order_id "select order_id from ec_orders where user_session_id=:user_session_id and order_state='in_basket'" -default ""]

if { [empty_string_p $order_id] } {
    ad_returnredirect index
    return
}

# this isn't necessary for security, but might as well do it anyway,
# so they don't get confused thinking the order they probably
# just submitted before pressing Back failed again:
# make sure there's something in their shopping cart, otherwise
# redirect them to their shopping cart which will tell them
# that it's empty.

if { [db_string get_ec_item_count_inbasket "select count(*) from ec_items where order_id=:order_id"] == 0 } {
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

# make sure there is a credit card for this order, otherwise
# they've probably gotten here via url surgery, so redirect them to checkout-2.tcl
# and while we're here, get the credit card info to pre-fill the form

if { [db_0or1row get_cc_info "select creditcard_type, creditcard_number, creditcard_expire, billing_zip_code from 
ec_creditcards, ec_orders
where ec_creditcards.creditcard_id=ec_orders.creditcard_id
and order_id=:order_id"] == 0 } {
    ad_returnredirect checkout-2
    return
}

# check done
# set the credit card variables


set ec_creditcard_widget [ec_creditcard_widget $creditcard_type]
set ec_expires_widget "[ec_creditcard_expire_1_widget [string range $creditcard_expire 0 1]] [ec_creditcard_expire_2_widget [string range $creditcard_expire 3 4]]"
db_release_unused_handles
ec_return_template





