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

set previous_product_id_p 0
set previous_product_id 0

if {[info exists product_id]} {
    set previous_product_id_p 1
    set previous_product_id $product_id
} 

# We don't need them to be logged in, but if they are they might get a
# lower price
set first_names ""
set last_name ""
set email ""

set user_id [ad_verify_and_get_user_id]
if { $user_id != 0 } {
    ad_get_user_info
}

# user sessions:
# 1. get user_session_id from cookie
# 2. if user has no session (i.e. user_session_id=0), attempt to set it if it hasn't been
#    attempted before
# 3. if it has been attempted before, give them message that we can't do shopping carts
#    without cookies

set user_session_id [ec_get_user_session_id]
ec_create_new_session_if_necessary

# This is not being used anywhere
#set n_items_in_cart [db_string get_n_items "
#    select count(*) 
#    from ec_orders o, ec_items i
#    where o.order_id=i.order_id
#    and o.user_session_id=:user_session_id and o.order_state='in_basket'"]

set product_counter 0
set total_price 0

db_multirow in_cart get_products_in_cart "
      select p.product_name, p.one_line_description, p.product_id, count(*) as quantity, u.offer_code, i.color_choice, i.size_choice, i.style_choice, '' as price 
      from ec_orders o
      join ec_items i on (o.order_id=i.order_id)
      join ec_products p on (i.product_id=p.product_id)
      left join (select product_id, offer_code 
	  from ec_user_session_offer_codes usoc 
	  where usoc.user_session_id=:user_session_id) u on (p.product_id=u.product_id)
      where o.user_session_id=:user_session_id 
      and o.order_state='in_basket'
      group by p.product_name, p.one_line_description, p.product_id, u.offer_code, i.color_choice, i.size_choice, i.style_choice"

for {set i 1} {$i <= [multirow size in_cart]} {incr i} {

    set product_name [multirow get in_cart $i product_name]
    set one_line_description [multirow get in_cart $i one_line_description]
    set product_id [multirow get in_cart $i product_id]
    set quantity [multirow get in_cart $i quantity]
    set offer_code [multirow get in_cart $i offer_code]
    set color_choice [multirow get in_cart $i color_choice]
    set size_choice [multirow get in_cart $i size_choice]
    set style_choice [multirow get in_cart $i style_choice]

    # Deletions are done by product_id, color_choice, size_choice,
    # style_choice, not by item_id because we want to delete the
    # entire quantity of that product.  Also print the price for a
    # product of the selected options and the aforementioned delete
    # option.

    set price_line [ec_price_line $product_id $user_id $offer_code]
    set delete_export_vars [export_url_vars product_id color_choice size_choice style_choice]

    # Too bad I have to do another call to get the price. That is
    # because ec_price_line returns canned html instead of the price.

    set lowest_price_and_price_name [ec_lowest_price_and_price_name_for_an_item $product_id $user_id $offer_code]
    set lowest_price [lindex $lowest_price_and_price_name 0]

    # Add the price of the item to the total price

    set total_price [expr $total_price + ($quantity * $lowest_price)]
    incr product_counter $quantity

    multirow set in_cart $i price "[lindex $lowest_price_and_price_name 1]:&nbsp;&nbsp;[ec_pretty_price [lindex $lowest_price_and_price_name 0] [ad_parameter -package_id [ec_id] Currency]]"

    multirow set in_cart $i price "[lindex $lowest_price_and_price_name 1]:&nbsp;&nbsp;[ec_pretty_price [lindex $lowest_price_and_price_name 0] [ad_parameter -package_id [ec_id] Currency]]"
}

# Add adjust quantities line if there are products in the cart.
set pretty_total_price [ec_pretty_price $total_price [ad_parameter -package_id [ec_id] Currency]]

# List the states that get charged tax. Although not 100% accurate
# as shipping might be taxed too this is better than nothing.

db_multirow -extend { pretty_tax } tax_entries tax_states "
 	select tax_rate, initcap(state_name) as state 
	from ec_sales_tax_by_state tax, us_states state 
	where state.abbrev = tax.usps_abbrev" {
		set pretty_tax "[format %0.2f [expr $tax_rate * 100]]%"
}

# bottom links:
# 1) continue shopping (always and already created)
# 2) log in (if they're not logged in)
# 3) retrieve a saved cart (if they are logged in and they have a saved cart)
# 4) save their cart (if their cart is not empty)

if { $user_id == 0 } {

    # Case 2) the user is not logged in.
    set return_url [ns_urlencode "[ec_url]"]

} else {
    # Case 3) Retrieve saved carts
    set saved_carts_p [db_string check_for_saved_carts "
	select 1 
	from dual 
	where exists (
	    select 1 
	    from ec_orders 
	    where user_id=:user_id 
	    and order_state='in_basket' 
	    and saved_p='t')" -default ""]
}

set context_bar [template::adp_parse [acs_root_dir]/packages/[ad_conn package_key]/www/contextbar [list context_addition [list "Shopping Cart"]]]
set ec_system_owner [ec_system_owner]
db_release_unused_handles
ad_return_template
