ad_page_contract {

    @param usca_p User session begun or not

    @author
    @creation-date
    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse <bart.teeuwisse@7-sisters.com>
    @revision-date April 2002

} {
    usca_p:optional
}

# We need them to be logged in

set user_id [ad_verify_and_get_user_id]
if {$user_id == 0} {
    set return_url "[ad_conn url]"
    ad_returnredirect "/register?[export_url_vars return_url]"
    ad_script_abort
}

# Cases that have to be dealt with:
# 1. User has no saved carts.
# 2. User has saved cart(s) and no current cart.
# 3. User has saved cart(s) and one current cart.

set saved_carts ""

# user session tracking

set user_session_id [ec_get_user_session_id]
ec_create_new_session_if_necessary "" shopping_cart_required

db_foreach get_basket_info "
    select to_char(o.in_basket_date,'Month DD, YYYY') as formatted_in_basket_date, o.in_basket_date, o.order_id, count(*) as n_products
    from ec_orders o, ec_items i
    where user_id=:user_id
    and order_state='in_basket'
    and saved_p='t'
    and i.order_id=o.order_id
    group by o.order_id, to_char(o.in_basket_date,'Month DD, YYYY'), o.in_basket_date
    order by o.in_basket_date" {

    append saved_carts "
	<form method=post action=\"shopping-cart-retrieve-3\">
	  [export_form_vars order_id]
	  <ul>
	    <li>$formatted_in_basket_date, $n_products item(s)
		<input type=submit name=submit value=\"View\">
		<input type=submit name=submit value=\"Retrieve\">
		<input type=submit name=submit value=\"Discard\"></li>
	  </ul>
	</form>"
} if_no_rows {
    append saved_carts "No shopping carts were found.\n"
}

set context_bar [template::adp_parse [acs_root_dir]/packages/[ad_conn package_key]/www/contextbar [list context_addition [list "Select Shopping Cart"]]]
set ec_system_owner [ec_system_owner]

db_release_unused_handles
ad_return_template
