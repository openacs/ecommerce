#  www/ecommerce/payment.tcl
ad_page_contract {
This script has to check whether the user has a gift_certificate that can cover the
 cost of the order and, if not, present credit card form
  @author
  @creation-date
  @cvs-id payment.tcl,v 3.2.6.7 2000/08/18 21:46:34 stevenp Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
}


ec_redirect_to_https_if_possible_and_necessary


# we need them to be logged in
set user_id [ad_verify_and_get_user_id]

if {$user_id == 0} {
    
    set return_url "[ad_conn url]"

    ad_returnredirect "/register?[export_url_vars return_url]"
    return
}

# make sure they have an in_basket order, otherwise they've probably
# gotten here by pushing Back, so return them to index.tcl

# user session tracking
set user_session_id [ec_get_user_session_id]


ec_create_new_session_if_necessary
# type1


ec_log_user_as_user_id_for_this_session

set success_p [db_0or1row get_order_id_and_order_owner "
       select order_id, 
              shipping_address as address_id,
              user_id as order_owner
         from ec_orders 
        where user_session_id=:user_session_id 
          and order_state='in_basket'
       "]


if { ! $success_p } {
    # No rows came back, so they probably got here by pushing "Back", so just redirect them
    # to index.tcl
    ad_returnredirect index.tcl
    return
} 

if { $order_owner != $user_id || [empty_string_p $address_id] } {

    # make sure the order belongs to this user_id (why?  because before this point there was no
    # personal information associated with the order (so it was fine to go by user_session_id), 
    # but now there is, and we don't want someone messing with their user_session_id cookie and
    # getting someone else's order)

    # if they get here,
    # either they managed to skip past checkout.tcl, or they messed
    # w/their user_session_id cookie;

    # address_id should already be in the database for this order
    # otherwise they've probably gotten here via url surgery, so redirect them
    # to checkout.tcl
    
    ad_returnredirect checkout.tcl
    return
}

# make sure there's something in their shopping cart, otherwise
# redirect them to their shopping cart which will tell them
# that it's empty.

if { [db_string get_ec_item_cart_count "select count(*) from ec_items where order_id=:order_id"] == 0 } {
    ad_returnredirect shopping-cart.tcl
    return
}


# everything is ok now; the user has a non-empty in_basket order and an
# address associated with it, so now get the other necessary information

set form_action [ec_securelink [ec_url]process-payment.tcl]
#  if { [ad_ssl_available_p] } {
#      set form_action "[ec_secure_location][ec_url]process-payment.tcl"
#  } else {
#      set form_action "[ec_insecure_location][ec_url]process-payment.tcl"
#  }

# ec_order_cost returns price + shipping + tax - gift_certificate BUT no gift certificates have been applied to
# in_basket orders, so this just returns price + shipping + tax

db_1row get_order_cost "
     select ec_order_cost(:order_id) as otppgc,
            ec_gift_certificate_balance(:user_id) as user_gift_certificate_balance
       from dual
     "

# Had to do this because the variable name below is too long for Oracle.
# It should be changed, but not in this upgrade
# hbrock@arsdigita.com
set order_total_price_pre_gift_certificate $otppgc
unset otppgc

# I know these variable names look kind of retarded, but I think they'll
# make things clearer for non-programmers editing the ADP templates:
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
    
    set customer_can_use_old_credit_cards 1

    # see if the administrator lets customers reuse their credit cards
    if { [ad_parameter -package_id [ec_id] SaveCreditCardDataP ecommerce] } {
	# then see if we have any credit cards on file for this user
	# for this shipping address only (for security purposes)
	set to_print_before_creditcards "<table>
	<tr><td></td><td><b>Card Type</b></td><td><b>Last 4 Digits</b></td><td><b>Expires</b></td></tr>"
	
	set card_counter 0
	set old_cards_to_choose_from ""

	db_foreach get_creditcards_onfile "select c.creditcard_id, c.creditcard_type, c.creditcard_last_four, c.creditcard_expire
	from ec_creditcards c
	where c.user_id=:user_id
	and c.creditcard_number is not null
	and c.failed_p='f'
	and 0 < (select count(*) from ec_orders o where o.creditcard_id=c.creditcard_id and o.shipping_address=$address_id)
	order by c.creditcard_id desc" {
	
	    if { $card_counter == 0 } {
		append old_cards_to_choose_from $to_print_before_creditcards
	    }
	    append old_cards_to_choose_from "<tr><td><input type=radio name=creditcard_id value=\"$creditcard_id\""
	    if { $card_counter == 0 } {
		append old_cards_to_choose_from " checked"
	    }
	    append old_cards_to_choose_from "></td><td>[ec_pretty_creditcard_type $creditcard_type]</td><td align=center>$creditcard_last_four</td><td align=right>$creditcard_expire</td></tr>\n
	    "
	    incr card_counter
	} if_no_rows {
	    set customer_can_use_old_credit_cards 0
	}

    }
    
    set ec_creditcard_widget [ec_creditcard_widget]
    set ec_expires_widget "[ec_creditcard_expire_1_widget] [ec_creditcard_expire_2_widget]"
    set zip_code [db_string get_zip_code "select zip_code from ec_addresses where address_id=:address_id"]
    # if customer_can_use_old_credit_cards is 0, we don't have to worry about what's
    # in old_cards_to_choose_from because it won't get printed in the template
    # anyway.

    append old_cards_to_choose_from "</table>"
    
}

db_release_unused_handles




ec_return_template
