#  www/ecommerce/shopping-cart-save.tcl
ad_page_contract {
    This page either redirects them to log on or asks them to confirm that they are who we think they are.

    @author
    @creation-date
    @cvs-id shopping-cart-save.tcl,v 3.1.6.4 2000/07/31 17:56:40 ryanlee Exp
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
}

set user_id [ad_verify_and_get_user_id]

set return_url "[ec_url]shopping-cart-save-2"

if {$user_id == 0} {
    ad_returnredirect "/register?[export_url_vars return_url]"
    return
}

set user_name [db_string get_full_name "select first_names || ' ' || last_name as user_name from cc_users where user_id=:user_id"]
set register_link "/register?[export_url_vars return_url]"
db_release_unused_handles

ec_return_template