ad_page_contract {

    @author
    @creation-date
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse <bart.teeuwisse@7-sisters.com>
    @revision-date April 2002

} {
    address_id:notnull
}

# We need them to be logged in
set user_id [ad_verify_and_get_user_id]
if {$user_id == 0} {
    set return_url "[ad_conn url]"
    ad_returnredirect "/register?[export_url_vars return_url]"
    ad_script_abort
}

# Make sure they have an in_basket order and a user_session_id; this
# will make it more annoying for someone who just wants to come to
# this page and try random number after random number

set user_session_id [ec_get_user_session_id]
if { $user_session_id == 0 } {
    rp_internal_redirect "index"
    ad_script_abort
}

set order_id [db_string get_order_id_for_claim "
    select order_id 
    from ec_orders 
    where user_session_id = :user_session_id 
    and order_state='in_basket'" -default ""]
if { [empty_string_p $order_id] } {
    rp_internal_redirect "index"
    ad_script_abort
}

set context_bar [template::adp_parse [acs_root_dir]/packages/[ad_conn package_key]/www/contextbar [list context_addition [list "Claim a Gift Certificate"]]]
set ec_system_owner [ec_system_owner]
