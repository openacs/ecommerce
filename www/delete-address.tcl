ad_page_contract {

    Set the ecommerce address with ID address_id to deleted so that
    it will no longer be available.

    @param address_id
    @param referer

    @author Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @creation-date April 2002
} {
    address_id
    referer
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
db_release_unused_handles

# Return to the calling page (E.g. checkout, billing,
# giftcertificate-billing).

rp_internal_redirect $referer
