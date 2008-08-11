ad_page_contract {

    This page either redirects them to log on or asks them to
    confirm that they are who we think they are.

    @author
    @creation-date
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @revision-date April 2002

} {
}

set user_id [ad_conn user_id]
set return_url "[ec_url]shopping-cart-save-2"
if {$user_id == 0} {
    ad_returnredirect "/register?[export_url_vars return_url]"
    ad_script_abort
}

set user_name [db_string get_full_name "
    select first_names || ' ' || last_name as user_name 
    from cc_users 
    where user_id=:user_id"]
set register_link "/register?[export_url_vars return_url]"
set title "Save Shopping Cart"
set context [list $title]
set ec_system_owner [ec_system_owner]

db_release_unused_handles
ad_return_template
