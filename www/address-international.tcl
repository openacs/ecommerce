ad_page_contract {
    @param address_type
    @param usca_p:optional
    @param address_id:optional

    @author
    @creation-date
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse <bart.teeuwisse@7-sisters.com>
    @revision-date April 2002

} {
    address_type
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

# Get the location from which delete-address was called.

set header_set [ns_conn headers]
set action [ns_set get [ns_conn headers] Referer]
# This will set "action" to be "foo" out of "http://bar.com/baz/foo"
set action [string range $action [expr [string last "/" $action] +1] end]

# Get the form vars that were passed on delete-address so that they
# can be passed back to the calling url. gift-certificate-billing has
# a bunch of form vars that should not be lost.

set hidden_form_vars "[export_form_vars action]"
set form_set [ns_getform]
for {set i 0} {$i < [ns_set size $form_set]} {incr i} {
    set [ns_set key $form_set $i] [ns_set value $form_set $i]
    append hidden_form_vars "[export_form_vars [ns_set key $form_set $i]]"
}

db_release_unused_handles
