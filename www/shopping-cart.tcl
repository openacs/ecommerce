ad_page_contract {
    @param usca_p User session begun or not

    @author
    @creation-date
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse <bart.teeuwisse@7-sisters.com>
    @revision-date April 2002

} {
    usca_p:optional
    product_id:optional
}

# bottom links:
# 1) continue shopping (always)

# Case 1) Continue shopping
# Create the link now before the product_id gets overwritten when
# looping through the products in the cart.

if {[info exists product_id]} {
    set bottom_links "<li><a href=\"product?[export_url_vars product_id]\">Continue Shopping</a></li>"
} else {
    set bottom_links "<li><a href=\"index\">Continue Shopping</a></li>"
}

set cart_contents ""

# We don't need them to be logged in, but if they are they might get a
# lower price

set user_id [ad_verify_and_get_user_id]

# user sessions:
# 1. get user_session_id from cookie
# 2. if user has no session (i.e. user_session_id=0), attempt to set it if it hasn't been
#    attempted before
# 3. if it has been attempted before, give them message that we can't do shopping carts
#    without cookies

set user_session_id [ec_get_user_session_id]
ec_create_new_session_if_necessary
set n_items_in_cart [db_string get_n_items "
    select count(*) 
    from ec_orders o, ec_items i
    where o.order_id=i.order_id
    and o.user_session_id=:user_session_id and o.order_state='in_basket'"]

set product_counter 0
set total_price 0
db_foreach get_products_in_cart "
    select p.product_name, p.one_line_description, p.product_id, count(*) as quantity, u.offer_code, i.color_choice, i.size_choice, i.style_choice
    from ec_orders o, ec_items i, ec_products p, 
        (select product_id, offer_code from ec_user_session_offer_codes usoc where usoc.user_session_id=:user_session_id) u
    where i.product_id=p.product_id
    and o.order_id=i.order_id
    and p.product_id=u.product_id(+)
    and o.user_session_id=:user_session_id and o.order_state='in_basket'
    group by p.product_name, p.one_line_description, p.product_id, u.offer_code, i.color_choice, i.size_choice, i.style_choice" {

    # No products listed yet, print header.

    if { $product_counter == 0 } {
	append cart_contents "
	   <form method=post action=shopping-cart-quantities-change>
	     <center>
	       <table border=\"0\" cellspacing=\"0\" cellpadding=\"5\">
		  <tr bgcolor=\"cccccc\">
		     <td>Shopping Cart Items</td>
		     <td>Options</td>
		     <td>Quantity</td>
		     <td>Price/Item</td>
		     <td>Action</td>
		  </tr>"
    }

    # Prepare color, size and style option list

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

    # Print the product with name, selected options and quantity

    append cart_contents "
	<tr>
	  <td><a href=\"product?product_id=$product_id\">$product_name</a></td>
	  <td>$options</td>
	  <td><input type=text name=\"quantity.[list $product_id $color_choice $size_choice $style_choice]\" value=\"$quantity\" size=4 maxlength=4></td>"

    # Deletions are done by product_id, color_choice, size_choice,
    # style_choice, not by item_id because we want to delete the
    # entire quantity of that product.  Also print the price for a
    # product of the selected options and the aforementioned delete
    # option.

    append cart_contents "
	  <td>[ec_price_line $product_id $user_id $offer_code]</td>
	  <td><a href=\"shopping-cart-delete-from?[export_url_vars product_id color_choice size_choice style_choice]\">delete</a></td>
	</tr>"

    # Too bad I have to do another call to get the price. That is
    # because ec_price_line returns canned html instead of the price.

    set lowest_price_and_price_name [ec_lowest_price_and_price_name_for_an_item $product_id $user_id $offer_code]
    set lowest_price [lindex $lowest_price_and_price_name 0]

    # Add the price of the item to the total price

    set total_price [expr $total_price + ($quantity * $lowest_price)]
    incr product_counter $quantity
}

# Add adjust quantities line if there are products in the cart.

if { $product_counter != 0 } {
    append cart_contents "
      <tr bgcolor=\"cccccc\">
        <td colspan=\"2\">Total:</td>
        <td>$product_counter</td>
        <td align=\"right\">[ec_pretty_price $total_price [ad_parameter -package_id [ec_id] Currency]]</td>
        <td><input type=submit value=\"update\"></td>
      </tr>"

    # List the states that get charged tax. Although not 100% accurate
    # as shipping might be taxed too this better than nothing.

    db_foreach tax_states "
	select tax_rate, initcap(state_name) as state 
	from ec_sales_tax_by_state tax, us_states state 
	where state.abbrev = tax.usps_abbrev" {
	append cart_contents "
          <tr>
            <td colspan=\"5\">Residents of $state, please add [format %0.2f [expr $tax_rate * 100]]% tax.</td>
          </tr>"
    }
}

# Close product listing and add proceed to checkout button.

if { $product_counter != 0 } {
    append cart_contents "
	    </table>
          </center>
        </form>
    	<center>
    	  <form method=post action=\"checkout\">
      	    <input type=submit value=\"Proceed to Checkout\"><br>
    	  </form>
    	</center>"
} else {

    # There are no products in the cart.

    append cart_contents "
    	<center>Your Shopping Cart is empty.</center>"
}

# bottom links:
# 1) continue shopping (always and already created)
# 2) log in (if they're not logged in)
# 3) retrieve a saved cart (if they are logged in and they have a saved cart)
# 4) save their cart (if their cart is not empty)

if { $user_id == 0 } {

    # Case 2) the user is not logged in.

    append bottom_links "
      	  <li><a href=\"/register/index?return_url=[ns_urlencode "[ec_url]"]\">Log In</a></li>"
} else {
    if { ![empty_string_p [db_string check_for_saved_carts "
	select 1 
	from dual 
	where exists (
	    select 1 
	    from ec_orders 
	    where user_id=:user_id 
	    and order_state='in_basket' 
	    and saved_p='t')" -default ""]] } {

	# Case 3) Retrieve saved carts

	append bottom_links "<li><a href=\"shopping-cart-retrieve-2\">Retrieve a Saved Cart</a></li>"
    }
}

if { $product_counter != 0 } {

    # Case 4) Save non empty cart

    append bottom_links "<li><a href=\"shopping-cart-save\">Save Your Cart for Later</a></li>"
}

db_release_unused_handles
ad_return_template
