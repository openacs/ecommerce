ad_page_contract {

    Present the available billing addresses of the visitor.

    @param usca_p User session started or not

    @author Bart Teeuwisse <bart.teeuwisse@7-sisters.com>
    @creation-date April 2002

} {
    usca_p:optional
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
	return
    }
}

# Everything is ok now; the user has a non-empty in_basket order and
# an address associated with it, so now get the other necessary
# information

set address_type "billing"
set referer "billing"

# Present all saved addresses

template::query get_billing_addresses billing_addresses multirow "
    select address_id
    from ec_addresses
    where user_id=:user_id
    and address_type = 'billing'" -eval {

    set row(formatted) [ec_display_as_html [ec_pretty_mailing_address_from_ec_addresses $row(address_id)]]
    set address_id $row(address_id)
    set row(delete) "[export_form_vars address_id referer]"
    set row(edit) "[export_form_vars address_id address_type referer]"
    set row(use) "[export_form_vars address_id]"
}

# Offer the shipping address if no billing addresses on file.

if {[template::multirow size billing_addresses] == 0} {
    template::query get_shipping_addresses shipping_addresses multirow "
	select shipping_address as address_id
	from ec_orders 
	where order_id = :order_id
	and shipping_address is not null" -eval {

	set row(formatted) [ec_display_as_html [ec_pretty_mailing_address_from_ec_addresses $row(address_id)]]
	set row(use) "[export_form_vars address_id]"
    }
}
set hidden_form_vars [export_form_vars address_type referer]

db_release_unused_handles
