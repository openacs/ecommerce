#  www/ecommerce/finalize-order.tcl
ad_page_contract {
 this script will:
 (1) put this order into the 'confirmed' state
 (2) try to authorize the user's credit card info and either
     (a) redirect them to a thank you page, or
     (b) redirect them to a "please fix your credit card info" page

    @author
    @creation-date
    @cvs-id finalize-order.tcl,v 3.3.6.9 2000/09/22 01:37:30 kevin Exp
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author and Walter McGinnis (wtem@olywa.net)
} {
}

# If they reload, we don't have to worry about the credit card
# authorization code being executed twice because the order has
# already been moved to the 'confirmed' state, which means that
# they will be redirected out of this page.
# We will redirect them to the thank you page which displays the
# order with the most recent confirmation date.
# The only potential problem is that maybe the first time the
# order got to this page it was confirmed but then execution of
# the page stopped before authorization of the order could occur.
# This problem is solved by the scheduled procedure,
# ec_query_for_cybercash_zombies, which will try to authorize
# any 'confirmed' orders over half an hour old.

ec_redirect_to_https_if_possible_and_necessary

# first do all the normal checks to make sure nobody is doing url
# or cookie surgery to get here

# we need them to be logged in
set user_id [ad_verify_and_get_user_id]

if {$user_id == 0} {
    
    set return_url "[ad_conn url]"

    ad_returnredirect "/register?[export_url_vars return_url]"
    template::adp_abort
}

# make sure they have an in_basket order
# unlike previous pages, if they don't have an in_basket order
# it may be because they tried to execute this code twice and
# the order is already in the confirmed state
# In this case, they should be redirected to the thank you
# page for the most recently confirmed order, if one exists,
# otherwise redirect them to index.tcl

# user session tracking
set user_session_id [ec_get_user_session_id]

ec_log_user_as_user_id_for_this_session

set order_id [db_string  get_order_id "select order_id from ec_orders where user_session_id=:user_session_id and order_state='in_basket'"  -default ""]

if { [empty_string_p $order_id] } {
    # find their most recently confirmed order
    set most_recently_confirmed_order [db_string get_mrc_order "
      select order_id 
        from ec_orders
       where user_id=:user_id
         and confirmed_date is not null
         and order_id=(
                       select max(o2.order_id)
                         from ec_orders o2
                        where o2.user_id=:user_id
                          and o2.confirmed_date is not null
                       )
    " -default ""]

    if { [empty_string_p $most_recently_confirmed_order] } {
	ad_returnredirect index
    } else {
	ad_returnredirect thank-you
    }
    template::adp_abort
}

# make sure there's something in their shopping cart, otherwise
# redirect them to their shopping cart which will tell them
# that it's empty.

# we may want to make this a redirect to insecure location
if { [db_string get_in_basket_count "select count(*) from ec_items where order_id=:order_id"] == 0 } {
    ad_returnredirect shopping-cart
    template::adp_abort
}

# make sure the order belongs to this user_id, otherwise they managed to skip past checkout.tcl, or
# they messed w/their user_session_id cookie
set order_owner [db_string get_order_owner "select user_id from ec_orders where order_id=:order_id"]

if { $order_owner != $user_id } {
    ad_returnredirect checkout
    template::adp_abort
}

# make sure there is an address for this order, otherwise they've probably
# gotten here via url surgery, so redirect them to checkout.tcl

set address_id [db_string get_a_shipping_address "select shipping_address from ec_orders where order_id=:order_id" -default ""]
if { [empty_string_p $address_id] } {
    ad_returnredirect checkout
    template::adp_abort
}

# make sure there is a credit card (or that the gift_certificate_balance covers the cost) and 
# a shipping method for this order, otherwise
# they've probably gotten here via url surgery, so redirect them to checkout-2.tcl

set creditcard_id [db_string get_creditcard_id "select creditcard_id from ec_orders where order_id=:order_id" -default ""]

if { [empty_string_p $creditcard_id] } {
    # we only want price and shipping from this (to determine whether gift_certificate covers cost)
    set price_shipping_gift_certificate_and_tax [ec_price_shipping_gift_certificate_and_tax_in_an_order $order_id]

    set order_total_price_pre_gift_certificate [expr [lindex $price_shipping_gift_certificate_and_tax 0] + [lindex $price_shipping_gift_certificate_and_tax 1]]

    set gift_certificate_balance [db_string get_gc_balance "select ec_gift_certificate_balance(:user_id) from dual"]
    
    if { $gift_certificate_balance < $order_total_price_pre_gift_certificate } {
	set gift_certificate_covers_cost_p "f"
    } else {
	set gift_certificate_covers_cost_p "t"
	 ec_update_state_to_authorized $order_id "authorized_plus_avs"
	ad_returnredirect thank-you
	template::adp_abort
    }
}

set shipping_method [db_string get_shipping_method "select shipping_method from ec_orders where order_id=:order_id" -default ""]


if { [empty_string_p $shipping_method] || ([empty_string_p $creditcard_id] && (![info exists gift_certificate_covers_cost_p] || $gift_certificate_covers_cost_p == "f")) } {
    ad_returnredirect checkout-2
    template::adp_abort
}


# done with all the checks!

# (1) put this order into the 'confirmed' state

db_transaction {

ec_update_state_to_confirmed $order_id

}

# (2) try to authorize the user's credit card info and either
#     (a) send them email & redirect them to a thank you page, or
#     (b) redirect them to a "please fix your credit card info" page

set cc_result [ec_creditcard_authorization $order_id]

if { [string equal $cc_result "authorized_plus_avs"] || [string equal $cc_result "authorized_minus_avs"] } {
    ec_email_new_order $order_id
    ec_update_state_to_authorized $order_id [ec_decode $cc_result "authorized_plus_avs" "t" "f"]
}

# wtem@olywa.net, 2001-03-21
# replaced string1 == string2 with [string equal string1 string2]
if { [string equal $cc_result "authorized_plus_avs"] || [string equal $cc_result "authorized_minus_avs"] || [string equal $cc_result "no_recommendation"] } {
    ad_returnredirect thank-you
    template::adp_abort
} elseif { [string equal $cc_result "failed_authorization"] } {
    # updates everything that needs to be updated if a confirmed offer fails
    ec_update_state_to_in_basket $order_id

    ad_returnredirect credit-card-correction
    template::adp_abort
} else {
    # Then cc_result is probably "invalid_input".
    # This should never occur
    ns_log Notice "Order $order_id received a cc_result of $cc_result"
    ad_return_error "Sorry" "
<h2>Sorry</h2>
There has been an error in the processing of your credit card information.  Please contact <a href=\"mailto:[ec_system_owner]\"><address>[ec_system_owner]</address></a> to report the error.
[ad_footer]
"
}


