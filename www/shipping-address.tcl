#  www/ecommerce/shipping-address.tcl
ad_page_contract {
    @param usca_p:optional
    @param address_id:optional
    @author
    @creation-date
    @cvs-id shipping-address.tcl,v 3.1.6.5 2000/08/18 21:46:35 stevenp Exp
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author Bart Teeuwisse <bart.teeuwisse@7-sisters.com>
} {
    usca_p:optional
    address_id:optional
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
ec_log_user_as_user_id_for_this_session

# Retrieve the default name of the person to ship to.
set attn [db_string get_full_name "select first_names || ' ' || last_name as name from cc_users where user_id=:user_id"]

# Retrieve the saved address with address_id. 
if { [info exists address_id] } {
    db_0or1row shipping_address "select attn, line1, line2, city, usps_abbrev, zip_code, phone, country_code, full_state_name, phone_time from ec_addresses where address_id=:address_id"
}

set user_name_with_quotes_escaped [ad_quotehtml $attn]

db_release_unused_handles
if { [info exists usps_abbrev] } {
    set state_widget [state_widget $usps_abbrev]
} else {
    set state_widget [state_widget]
}

ec_return_template