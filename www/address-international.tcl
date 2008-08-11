ad_page_contract {
    @param address_type
    @param usca_p:optional
    @param address_id:optional
    @param referer

    @author
    @creation-date
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @revision-date April 2002

} {
    address_type
    usca_p:optional
    address_id:optional
    referer
}

# we need them to be logged in

set user_id [ad_conn user_id]
if {$user_id == 0} {
    set return_url "[ad_conn url]"
    ad_returnredirect "/register?[export_url_vars return_url]"
    ad_script_abort
}

# user session tracking

set user_session_id [ec_get_user_session_id]
ec_create_new_session_if_necessary

# Retrieve the saved address with address_id. 

if { [info exists address_id] } {
    db_0or1row select_address "
        select attn, line1, line2, city, usps_abbrev, zip_code, phone, country_code, full_state_name, phone_time 
	from ec_addresses 
	where address_id=:address_id"
    set country_widget [ec_country_widget $country_code]
} else {
    set country_widget [ec_country_widget]

    # Retrieve the default name.

    # get the separate fields for card processing
    db_0or1row get_names "
	select first_names, last_name
	from cc_users
	where user_id=:user_id"
    # we could use a single name field for shipping
    # but shipping address becomes default for billing!
    # attn has a 3 space delimiter for parsing last/first names

    # set attn just in case it gets used
    # avoid using it for single field name entry. 
    set attn "$first_names   $last_name"

}

# set the defaults for name fields if they are empty
if {[info exists last_name] != 1} {
   if {[info exists attn]} {
    # delimiter is triple space (for parsing).
        set name_delim [string first "   " $attn]
        if {$name_delim < 0 } {
            set name_delim 0
        }
        set first_names [string trim [string range $attn 0 $name_delim]]
        set last_name [string range $attn [expr $name_delim + 3 ] end]
    }
}
set user_last_name_with_quotes_escaped [ad_quotehtml $last_name]
set user_first_names_with_quotes_escaped [ad_quotehtml $first_names]

set user_name_with_quotes_escaped [ad_quotehtml $attn]

# Get the form vars that were passed on delete-address so that they
# can be passed back to the calling url. gift-certificate-billing has
# a bunch of form vars that should not be lost.

set form_set [ns_getform]
for {set i 0} {$i < [ns_set size $form_set]} {incr i} {
    set [ns_set key $form_set $i] [ns_set value $form_set $i]
    append hidden_form_vars "[export_form_vars [ns_set key $form_set $i]]"
}

set title "Completing Your Order"
if { $address_type eq "shipping" } {
    append title ": your shipping address"
} else {
    append title ": your billing address"
}
set context [list $title]
set ec_system_owner [ec_system_owner]
db_release_unused_handles
