#  www/ecommerce/shopping-cart.tcl
ad_page_contract {
    @param usca_p User session begun or not

    @author
    @creation-date
    @cvs-id shopping-cart.tcl,v 3.4.2.10 2000/08/18 18:42:42 hbrock Exp
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    usca_p:optional
}


set cart_contents ""

# we don't need them to be logged in, but if they are they might get a lower price
set user_id [ad_verify_and_get_user_id]

# user sessions:
# 1. get user_session_id from cookie
# 2. if user has no session (i.e. user_session_id=0), attempt to set it if it hasn't been
#    attempted before
# 3. if it has been attempted before, give them message that we can't do shopping carts
#    without cookies

set user_session_id [ec_get_user_session_id]

ec_create_new_session_if_necessary

set n_items_in_cart [db_string get_n_items "select count(*) from
ec_orders o, ec_items i
where o.order_id=i.order_id
and o.user_session_id=:user_session_id and o.order_state='in_basket'"]

set product_counter 0
db_foreach get_products_in_cart "select p.product_name, p.one_line_description, p.product_id, count(*) as quantity, u.offer_code, i.color_choice, i.size_choice, i.style_choice
from ec_orders o, ec_items i, ec_products p, 
(select product_id, offer_code from ec_user_session_offer_codes usoc where usoc.user_session_id=:user_session_id) u
where i.product_id=p.product_id
and o.order_id=i.order_id
and p.product_id=u.product_id(+)
and o.user_session_id=:user_session_id and o.order_state='in_basket'
group by p.product_name, p.one_line_description, p.product_id, u.offer_code, i.color_choice, i.size_choice, i.style_choice" {


    if { $product_counter == 0 } {
	append cart_contents "<form method=post action=shopping-cart-quantities-change>
	<center>
	<table border=0 cellspacing=0 cellpadding=5>
	<tr bgcolor=\"cccccc\"><td>Shopping Cart Items</td><td>Options</td><td>Qty.</td><td>&nbsp;</td><td>&nbsp;</td></tr>\n"
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
    set options [join $option_list "<br>"]

    append cart_contents "<tr><td>
    <a href=\"product?product_id=$product_id\">$product_name</a></td>
    <td>$options</td>
    <td><input type=text name=\"quantity.[list $product_id $color_choice $size_choice $style_choice]\" value=\"$quantity\" size=4 maxlength=4>
   
  
</td>
    "
    # deletions are done by product_id, color_choice, size_choice, style_choice,
    # not by item_id because we want to delete the entire quantity of that product
    append cart_contents "<td>[ec_price_line $product_id $user_id $offer_code]</td>
    <td><a href=\"shopping-cart-delete-from?[export_url_vars product_id color_choice size_choice style_choice]\">delete</a></td>
    </tr>
    "
    incr product_counter
}

if { $product_counter != 0 } {
    append cart_contents "<tr><td align=right>If you changed any quantities, please press this button to</td>
    <td><input type=submit value=\"update\"></td><td></td><td></td></tr>"
}

if { $product_counter != 0 } {
    append cart_contents "</table>
    </center>
    </form>
    <center>
    <form method=post action=\"checkout\">
    <input type=submit value=\"Proceed to Checkout\"><br>
    </form>
    </center>
    "
} else {
    append cart_contents "<center>Your Shopping Cart is empty.</center>
    "
}

# bottom links:
# 1) continue shopping (always)
# 2) log in (if they're not logged in)
# 3) retrieve a saved cart (if they are logged in and they have a saved cart)
# 4) save their cart (if their cart is not empty)

set bottom_links "<li><a href=\"index\">Continue Shopping</a>\n"

if { $user_id == 0 } {
    append bottom_links "<li><a href=\"/register/index?return_url=[ns_urlencode "[ec_url]"]\">Log In</a>\n"
} else {
    # see if they have any saved carts
    if { ![empty_string_p [db_string  check_for_saved_carts "select 1 from dual where exists (select 1 from ec_orders where user_id=:user_id and order_state='in_basket' and saved_p='t')" -default ""]] } {
	append bottom_links "<li><a href=\"shopping-cart-retrieve-2\">Retrieve a Saved Cart</a>\n"
    }
}

if { $product_counter != 0 } {
    append bottom_links "<li><a href=\"shopping-cart-save\">Save Your Cart for Later</a>\n"
}

db_release_unused_handles
ec_return_template






