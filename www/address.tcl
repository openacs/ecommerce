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

ec_redirect_to_https_if_possible_and_necessary

# we need them to be logged in

set user_id [ad_conn user_id]
if {$user_id == 0} {
    set return_url "[ad_conn url]"
    ad_returnredirect "/register?[export_url_vars return_url]"
    ad_script_abort
}

# Retrieve the saved address with address_id. 

if { [info exists address_id] } {
    db_0or1row select_address "
	select attn, line1, line2, city, usps_abbrev, zip_code, phone, country_code, full_state_name, phone_time 
	from ec_addresses 
	where address_id=:address_id"

    if {[info exists attn]} {
    # delimiter is triple space (for parsing).
        set name_delim [string first "   " $attn]
        if {$name_delim < 0 } {
            set name_delim 0
        }
        set first_names [string trim [string range $attn 0 $name_delim]]
        set last_name [string range $attn [expr $name_delim + 3 ] end]
    }

    # Redirect to the international address form if the address is
    # outside the United States.

    if { ![string equal $country_code "US"] } {
	ad_returnredirect "address-international?[export_url_vars address_id address_type referer]"
        ad_script_abort
    }

    if { [info exists usps_abbrev] } {
	set state_widget [state_widget $usps_abbrev]
    }
} else {

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

    set attn [db_string get_full_name "
    	select first_names || '   ' || last_name as name 
    	from cc_users 
    	where user_id=:user_id"]

}
if { ![info exists state_widget] } {
    set state_widget [state_widget]
}

# User session tracking

set user_session_id [ec_get_user_session_id]
ec_create_new_session_if_necessary
ec_log_user_as_user_id_for_this_session

# Get the location from which address was called.

# set header_set [ns_conn headers]
# set referer [ns_set get [ns_conn headers] Referer]
# # This will set "referer" to be "foo" out of "http://bar.com/baz/foo"
# set referer [string range $referer [expr [string last "/" $referer] + 1] end]

# Get the form vars that were passed on delete-address so that they
# can be passed back to the calling url. gift-certificate-billing has
# a bunch of form vars that should not be lost.

set form_set [ns_getform]
for {set i 0} {$i < [ns_set size $form_set]} {incr i} {
    set [ns_set key $form_set $i] [ns_set value $form_set $i]
    append hidden_form_vars "[export_form_vars [ns_set key $form_set $i]]"
}

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
set context_bar [template::adp_parse [acs_root_dir]/packages/[ad_conn package_key]/www/contextbar [list context_addition [list "Completing Your Order"]]]
set ec_system_owner [ec_system_owner]
db_release_unused_handles
