ad_page_contract {

    @author
    @creation-date
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @revision-date April 2002

} {
}

set user_id [ad_conn user_id]
if {$user_id == 0} {
    set return_url "[ad_conn url]"
    ad_returnredirect "/register?[export_url_vars return_url]"
    ad_script_abort
}

set user_session_id [ec_get_user_session_id]
if { $user_session_id == 0 } {

    doc_return  200 text/html "
	[ad_header "No Cart Found"]

	<h2>No Shopping Cart Found</h2>
    	<p>We could not find any shopping cart for you.  This may be because you have cookies 
    	   turned off on your browser.  Cookies are necessary in order to have a shopping cart
    	   system so that we can tell which items are yours.</p>

    	<p><i>In Netscape 4.0 and later, you can enable cookies from Edit -> Preferences -> Advanced.</i></p>

    	<p></i>In Microsoft Internet Explorer 4.0 and later, you can enable cookies from View -> 
    	   Internet Options -> Advanced -> Security. </i></p>
    	[ec_continue_shopping_options]"
    ad_script_abort
}

# Set the user_id of the order so that we'll know who it belongs to
# and remove the user_session_id so that they can't mess with their
# saved order (until they retrieve it, of course)

db_dml update_ec_orders "
    update ec_orders 
    set user_id=:user_id, user_session_id=null, saved_p='t'
    where user_session_id=:user_session_id 
    and order_state='in_basket'"

# This should have only updated 1 row, or 0 if they reload, which is
# fine

set cart_duration [ad_parameter CartDuration default [ad_parameter -package_id [ec_id] CartDuration]]
set context_bar [template::adp_parse [acs_root_dir]/packages/[ad_conn package_key]/www/contextbar [list context_addition [list "Your Shopping Cart Has Been Saved"]]]
set ec_system_owner [ec_system_owner]

db_release_unused_handles
ad_return_template
