#  www/ecommerce/shopping-cart-save-2.tcl
ad_page_contract {

    @author
    @creation-date
    @cvs-id shopping-cart-save-2.tcl,v 3.1.6.6 2000/09/22 01:37:31 kevin Exp
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
}

set user_id [ad_verify_and_get_user_id]

if {$user_id == 0} {
    
    set return_url "[ad_conn url]"

    ad_returnredirect "/register?[export_url_vars return_url]"
    return
}

set user_session_id [ec_get_user_session_id]

if { $user_session_id == 0 } {
    doc_return  200 text/html "[ad_header "No Cart Found"]<h2>No Shopping Cart Found</h2>
    <p>
    We could not find any shopping cart for you.  This may be because you have cookies 
    turned off on your browser.  Cookies are necessary in order to have a shopping cart
    system so that we can tell which items are yours.

    <p>
    <i>In Netscape 4.0, you can enable cookies from Edit -> Preferences -> Advanced. <br>

    In Microsoft Internet Explorer 4.0, you can enable cookies from View -> 
    Internet Options -> Advanced -> Security. </i>

    <p>

    [ec_continue_shopping_options]
    "
    return
}

# set the user_id of the order so that we'll know who it belongs to
# and remove the user_session_id so that they can't mess with their
# saved order (until they retrieve it, of course)

db_dml update_ec_orders "update ec_orders set user_id=:user_id, user_session_id=null, saved_p='t'
where user_session_id=:user_session_id and order_state='in_basket'"

# this should have only updated 1 row, or 0 if they reload, which is fine
db_release_unused_handles

ec_return_template


