# /www/ecommerce/checkout-2.tcl
ad_page_contract {
    @param address_id a stored address
    @param usca_p User session started or not

    @author
    @creation-date
    @cvs-id checkout-2.tcl,v 3.7.2.13 2000/08/18 21:46:32 stevenp Exp
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    address_id:optional,naturalnum
    usca_p:optional
}

# ec_redirect_to_https_if_possible_and_necessary

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

# type5
# make sure they have an in_basket order, otherwise they've probably
# gotten here by pushing Back, so return them to index.tcl

set success_p [db_0or1row get_order_id_and_order_owner "
       select order_id, 
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

if { $order_owner != $user_id } {

    # make sure the order belongs to this user_id (why?  because before this point there was no
    # personal information associated with the order (so it was fine to go by user_session_id), 
    # but now there is, and we don't want someone messing with their user_session_id cookie and
    # getting someone else's order)

    # if they get here,
    # either they managed to skip past checkout.tcl, or they messed
    # w/their user_session_id cookie;
    ad_returnredirect checkout.tcl
    return
}


# make sure there's something in their shopping cart, otherwise
# redirect them to their shopping cart which will tell them
# that it's empty.

if { [db_string get_ec_item_count "select count(*) from ec_items where order_id=:order_id"] == 0 } {
    ad_returnredirect shopping-cart
    return
}

# either address_id should be a form variable, or it should already
# be in the database for this order

# make sure address_id, if it exists, belongs to them, otherwise 
# they've probably gotten here by form surgery, in which case send
# them back to checkout.tcl
# if it is theirs, put it into the database for this order

# if address_id doesn't exist, make sure there is an address for this order, 
# otherwise they've probably gotten here via url surgery, so redirect them
# to checkout.tcl

if { [info exists address_id] && ![empty_string_p $address_id] } {

    set n_this_address_id_for_this_user [db_string get_an_address_id "select count(*) from ec_addresses where address_id=:address_id and user_id=:user_id"]
    if {$n_this_address_id_for_this_user == 0} {

	ad_returnredirect checkout
	return
    }
    # it checks out ok
    db_dml update_ec_order_address "update ec_orders set shipping_address=:address_id where order_id=:order_id"
} else {
    set address_id [db_string  get_address_id "select shipping_address from ec_orders where order_id=:order_id" -default ""]
    if { [empty_string_p $address_id] } {
	ad_returnredirect checkout
	return
    }
}

# everything is ok now; the user has a non-empty in_basket order and an
# address associated with it, so now get the other necessary information

#  array set drivers [ec_preferred_drivers]

#  if { [ad_ssl_available_p] } {
#      set ssl_port [ns_config -int "ns/server/[ns_info server]/module/$drivers(sdriver)" Port 443]
#      if { $ssl_port == 443 } {
#          set ssl_port ""
#      } else {
#          set ssl_port ":$ssl_port"
#      }
#      set form_action "https://[ns_config ns/server/[ns_info server]/module/$drivers(sdriver) Hostname]${ssl_port}[ec_url]process-order-quantity-shipping"
#  } else {
#      set form_action "http://[ns_config ns/server/[ns_info server]/module/$drivers(driver) Hostname][ec_url]process-order-quantity-shipping"
#  }

set form_action [ec_securelink [ec_url]process-order-quantity-shipping]
set rows_of_items ""

set shipping_avail_p 1

db_foreach get_shipping_data "
    select p.no_shipping_avail_p, p.product_name, p.one_line_description, p.product_id,
           count(*) as quantity,
           u.offer_code,
           i.color_choice, i.size_choice, i.style_choice
      from ec_orders o, ec_items i, ec_products p, 
           (select offer_code, product_id
              from ec_user_session_offer_codes usoc
             where usoc.user_session_id=:user_session_id) u
     where i.product_id=p.product_id
       and o.order_id=i.order_id
       and p.product_id= u.product_id(+)
       and o.user_session_id=:user_session_id and o.order_state='in_basket'
  group by p.no_shipping_avail_p, p.product_name, p.one_line_description, p.product_id,
           u.offer_code,
           i.color_choice, i.size_choice, i.style_choice" {

    if { [string compare $no_shipping_avail_p "t"] == 0 } {
        set shipping_avail_p 0
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

    # Trying out the fancy new . arrays. It would be much better to rework this
    # for a 2D array,multiple setup, but I don't have time to think about it now...
    append rows_of_items "<tr>
    <td><input type=text name=\"quantity.[list $product_id $color_choice $size_choice $style_choice]\" value=\"$quantity\" size=4 maxlength=4></td>
    <td><a href=\"product?product_id=$product_id\">$product_name</a>[ec_decode $options "" "" ", $options"]<br>
    [ec_price_line $product_id $user_id $offer_code]</td>
    </tr>
    "
}

set shipping_options ""
set checkout_step    verify

if { [ad_parameter -package_id [ec_id] ExpressShippingP ecommerce] } {
    if { $shipping_avail_p } {
        set checkout_step shipping
        append shipping_options "<p>
        <b><li>Shipping method:</b>
        <p>
        <input type=radio name=shipping_method value=\"standard\" checked>Standard Shipping<br>
        <input type=radio name=shipping_method value=\"express\">Express<br>
        <input type=radio name=shipping_method value=\"pickup\">Pickup
        <p>
        "
    } else {
        set shipping_method "no shipping"
        append shipping_options "<p>
        <b><li>No Shipping Available:</b>
        <p>
        [export_form_vars shipping_method]
        One or more items in your order are not shippable.
        <p>
        "
    }
}
set tax_exempt_options ""

if { [ad_parameter -package_id [ec_id] OfferTaxExemptStatusP ecommerce 0] } {
  append tax_exempt_options "<p>
  <b><li>Is your organization tax exempt? (If so, we will ask you to
  provide us with an exemption certificate.)</b>
  <p>
  <input type=radio name=tax_exempt_p value=\"t\">Yes<br>
  <input type=radio name=tax_exempt_p value=\"f\" checked>No"
}
db_release_unused_handles
ec_return_template
