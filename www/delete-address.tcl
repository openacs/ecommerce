ad_page_contract {

    Set the ecommerce address with ID address_id to deleted so that
    it will no longer be available.

    @param address_id

    @author Bart Teeuwisse <bart.teeuwisse@7-sisters.com>
    @creation-date April 2002
} {
    address_id
}

# Can't remove the address from the database as old orders might refer
# to the address.  By setting the address_type to 'deleted' the
# address will no longer be available for shipping. While still in the
# database the user can't use the address any more.

db_dml delete_address "
    update ec_addresses 
    set address_type = 'deleted' 
    where address_id = :address_id"

db_1row select_address "
    select * 
    from ec_addresses 
    where address_id = :address_id"

set deleted_address [ec_display_as_html [ec_pretty_mailing_address_from_args $line1 $line2 $city $usps_abbrev $zip_code $country_code \
						$full_state_name $attn $phone $phone_time]]

# Get the location from which delete-address was called.

set header_set [ns_conn headers]
set action [ns_set get [ns_conn headers] Referer]

# Get the form vars that were passed on delete-address so that they
# can be passed back to the calling url. gift-certificate-billing has
# a bunch of form vars that should not be lost.

set hidden_form_vars ""
set form_set [ns_getform]
for {set i 0} {$i < [ns_set size $form_set]} {incr i} {
    set [ns_set key $form_set $i] [ns_set value $form_set $i]
    append hidden_form_vars "[export_form_vars [ns_set key $form_set $i]]"
}

db_release_unused_handles
