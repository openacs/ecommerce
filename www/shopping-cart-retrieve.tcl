#  www/ecommerce/shopping-cart-retrieve.tcl
ad_page_contract {
    This page either redirects them to log on or asks them to confirm that they are who we think they are.

    @param usca_p User session begun or not

    @author
    @creation-date
    @cvs-id shopping-cart-retrieve.tcl,v 3.1.6.4 2000/07/31 18:00:12 ryanlee Exp
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    usca_p:optional
}


set user_id [ad_verify_and_get_user_id]

set return_url "[ec_url]shopping-cart-retrieve-2"

if {$user_id == 0} {
    ad_returnredirect "/register?[export_url_vars return_url]"
    return
}

# user session tracking
set user_session_id [ec_get_user_session_id]

ec_create_new_session_if_necessary "" shopping_cart_required
# typeA

ec_log_user_as_user_id_for_this_session

set user_name [db_string get_user_name "select first_names || ' ' || last_name as user_name from cc_users where user_id=:user_id"]

set register_link "/register?[export_url_vars return_url]"

db_release_unused_handles

ec_return_template

