#  www/ecommerce/shipping-address.tcl
ad_page_contract {
    @param usca_p:optional
  @author
  @creation-date
  @cvs-id shipping-address.tcl,v 3.1.6.5 2000/08/18 21:46:35 stevenp Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    usca_p:optional
}



# we need them to be logged in
set user_id [ad_verify_and_get_user_id]

if {$user_id == 0} {
    
    set return_url "[ad_conn url]"

    ad_returnredirect "/register?[export_url_vars return_url]"
    return
}

# user session tracking
set user_session_id [ec_get_user_session_id]


ec_create_new_session_if_necessary
# type1

ec_log_user_as_user_id_for_this_session

set user_name_with_quotes_escaped [ad_quotehtml [db_string get_full_name "select first_names || ' ' || last_name as name from cc_users where user_id=:user_id"]]
db_release_unused_handles
set state_widget [state_widget]

ec_return_template




