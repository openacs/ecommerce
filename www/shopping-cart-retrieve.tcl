ad_page_contract {
    This page either redirects them to log on or asks them to confirm that they are who we think they are.

    @param usca_p User session begun or not

    @author
    @creation-date
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse <bart.teeuwisse@7-sisters.com>
    @revision-date April 2002

} {
    usca_p:optional
}


set user_id [ad_verify_and_get_user_id]
set return_url "[ec_url]shopping-cart-retrieve-2"
if {$user_id == 0} {
    ad_returnredirect "/register?[export_url_vars return_url]"
    ad_script_abort
}

# User session tracking

set user_session_id [ec_get_user_session_id]
ec_create_new_session_if_necessary "" shopping_cart_required
ec_log_user_as_user_id_for_this_session
set user_name [db_string get_user_name "
    select first_names || ' ' || last_name as user_name 
    from cc_users 
    where user_id=:user_id"]

set register_link "/register?[export_url_vars return_url]"
set context_bar [template::adp_parse [acs_root_dir]/packages/[ad_conn package_key]/www/contextbar [list context_addition [list "Retrieve Shopping Cart"]]]
set ec_system_owner [ec_system_owner]

db_release_unused_handles
ad_return_template

