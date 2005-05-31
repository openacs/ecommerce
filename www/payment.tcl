ad_page_contract {

    This script has to check whether the user has a gift_certificate that can cover the
    cost of the order and, if not, present credit card form

    @author
    @creation-date
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @revision-date April 2002

} {
    address_id:integer,optional
    address_type:optional
}

ec_redirect_to_https_if_possible_and_necessary

# we need them to be logged in

set user_id [ad_verify_and_get_user_id]
if {$user_id == 0} {
    set return_url "[ad_conn url]"
    ad_returnredirect "/register?[export_url_vars return_url]"
    ad_script_abort
}

# Make sure they have an in_basket order, otherwise they've probably
# gotten here by pushing Back, so return them to index.tcl

# User session tracking

set user_session_id [ec_get_user_session_id]
ec_create_new_session_if_necessary
ec_log_user_as_user_id_for_this_session

# Store the input address_id as billing_address_id so that the next
# query won't overwrite it.

set billing_address_id $address_id

set success_p [db_0or1row get_order_id_and_order_owner "
    select order_id, 
    shipping_address as address_id,
    user_id as order_owner
    from ec_orders 
    where user_session_id=:user_session_id 
    and order_state='in_basket'"]
if { ! $success_p } {

    # No rows came back, so they probably got here by pushing "Back",
    # so just redirect them to index.tcl

    rp_internal_redirect index
    ad_script_abort
} 

if { $order_owner != $user_id } {

    # make sure the order belongs to this user_id (why?  because
    # before this point there was no personal information associated
    # with the order (so it was fine to go by user_session_id), but
    # now there is, and we don't want someone messing with their
    # user_session_id cookie and getting someone else's order)

    # if they get here, either they managed to skip past checkout.tcl,
    # or they messed w/their user_session_id cookie;

    # address_id should already be in the database for this order
    # otherwise they've probably gotten here via url surgery, so
    # redirect them to checkout.tcl
    
    rp_internal_redirect checkout
    ad_script_abort
}

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

# Make sure there's something in their shopping cart, otherwise
# redirect them to their shopping cart which will tell them that it's
# empty.

if { [db_string get_ec_item_cart_count "
    select count(*) 
    from ec_items 
    where order_id=:order_id"] == 0 } {
    ad_returnredirect shopping-cart
    ad_script_abort
}

# Everything is ok now; the user has a non-empty in_basket order and
# an address associated with it.

if {[info exists address_type] && [string equal $address_type "shipping"]} {

    set saved_user_id $user_id
    
    # Clone the shipping address and make it a billing address. This
    # allows the user to delete the billing address at a later point
    # without affecting the shipping address.

    if {[db_0or1row get_shipping_address "
	select * 
	from ec_addresses
	where address_id = :address_id"]} {

	set address_id [db_nextval ec_address_id_sequence]
	db_dml insert_new_address "
	    insert into ec_addresses
            (address_id, user_id, address_type, attn, line1, line2, city, usps_abbrev, zip_code, full_state_name, country_code, phone, phone_time)
            values
            (:address_id, :user_id, 'billing', :attn, :line1, :line2, :city, :usps_abbrev, :zip_code, :full_state_name, :country_code, :phone,:phone_time)"
    }
    set user_id $saved_user_id
}

# Now get the other necessary information

set form_action [ec_securelink [ec_url]process-payment]

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

# I know these variable names look kind of retarded, but I think
# they'll make things clearer for non-programmers editing the ADP
# templates:

set gift_certificate_covers_whole_order 0
set gift_certificate_covers_part_of_order 0
set customer_can_use_old_credit_cards 0

set show_creditcard_form_p "t"
if { $user_gift_certificate_balance >= $order_total_price_pre_gift_certificate } {
    set gift_certificate_covers_whole_order 1
    set show_creditcard_form_p "f"
} elseif { $user_gift_certificate_balance > 0 } {
    set gift_certificate_covers_part_of_order 1
    set certificate_amount [ec_pretty_price $user_gift_certificate_balance]
}

if { $show_creditcard_form_p == "t" } {
    set customer_can_use_old_credit_cards [ad_parameter -package_id [ec_id] SaveCreditCardDataP ecommerce]

    # See if the administrator lets customers reuse their credit cards

    if { [ad_parameter -package_id [ec_id] SaveCreditCardDataP ecommerce] } {

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
		  <td><input type=radio name=creditcard_id value=\"$creditcard_id\""
	    if { $card_counter == 0 } {
		append old_cards_to_choose_from " checked"
	    }
	    append old_cards_to_choose_from "
		></td>
		<td>[ec_pretty_creditcard_type $creditcard_type]</td>
		<td align=center>$creditcard_last_four</td>
		<td align=right>$creditcard_expire</td>
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

set context_bar [template::adp_parse [acs_root_dir]/packages/[ad_conn package_key]/www/contextbar [list context_addition [list "Completing Your Order"]]]
set ec_system_owner [ec_system_owner]
db_release_unused_handles
ad_return_template
