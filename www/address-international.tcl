ad_page_contract {
    @param address_type
    @param usca_p:optional
    @param address_id:optional
    @param referer

    @author
    @creation-date
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse <bart.teeuwisse@7-sisters.com>
    @revision-date April 2002

} {
    address_type
    usca_p:optional
    address_id:optional
    referer
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

# Retrieve the saved address with address_id. 

if { [info exists address_id] } {
    db_0or1row shipping_address "
	select *
	from ec_addresses 
	where address_id=:address_id"
    set country_widget [ec_country_widget $country_code]
} else {
    set country_widget [ec_country_widget]

    set attn [ad_quotehtml [db_string get_full_name "
	select first_names || ' ' || last_name as name 
	from cc_users 
	where user_id=:user_id"]]
}

# Get the form vars that were passed on delete-address so that they
# can be passed back to the calling url. gift-certificate-billing has
# a bunch of form vars that should not be lost.

set form_set [ns_getform]
for {set i 0} {$i < [ns_set size $form_set]} {incr i} {
    set [ns_set key $form_set $i] [ns_set value $form_set $i]
    append hidden_form_vars "[export_form_vars [ns_set key $form_set $i]]"
}

set context_bar [template::adp_parse [acs_root_dir]/packages/[ad_conn package_key]/www/contextbar [list context_addition [list "Completing Your Order"]]]
set ec_system_owner [ec_system_owner]
db_release_unused_handles
