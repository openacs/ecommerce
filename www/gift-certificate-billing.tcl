ad_page_contract {

    Present the available billing addresses of the visitor.

    @param usca_p User session started or not

    @author Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @creation-date April 2002

} {
    certificate_to:optional
    certificate_from:optional
    certificate_message:optional
    amount:notnull
    recipient_email:notnull,email
} -properties {
    addresses:multirow
}

ec_redirect_to_https_if_possible_and_necessary

# User must be logged in

set user_id [ad_conn user_id]
if {$user_id == 0} {
    set return_url "[ad_conn url]"
    ad_returnredirect "/register?[export_url_vars return_url]"
    ad_script_abort
}

# Error checking

set exception_count 0
set exception_text ""

if { [string length $certificate_message] > 200 } {
    incr exception_count
    append exception_text "
	<li>
	  The message you entered was too long. It needs to contain fewer than 200 characters (the current length is [string length $certificate_message] characters).
	</li>"
} 

if { [string length $certificate_to] > 100 } {
    incr exception_count
    append exception_text "
	<li>
	  What you entered in the \"To\" field is too long. It needs to contain fewer than 100 characters (the current length is [string length $certificate_to] characters).
	</li>"
} 

if { [string length $certificate_from] > 100 } {
    incr exception_count
    append exception_text "
	<li>
	  What you entered in the \"From\" field is too long. It needs to contain fewer than 100 characters (the current length is [string length $certificate_from] characters).
	</li>"
} 

if { [string length $recipient_email] > 100 } {
    incr exception_count
    append exception_text "
	<li>
	   The recipient email address you entered is too long.  It needs to contain fewer than 100 characters (the current length is [string length $recipient_email] characters).
	</li>"
}

if { $amount < [ad_parameter -package_id [ec_id] MinGiftCertificateAmount ecommerce] } {
    incr exception_count
    append exception_text "
	<li>
	  The amount needs to be at least [ec_pretty_price [ad_parameter -package_id [ec_id] MinGiftCertificateAmount ecommerce]]
	</li>"
} elseif { $amount > [ad_parameter -package_id [ec_id] MaxGiftCertificateAmount ecommerce] } {
    incr exception_count
    append exception_text "
	<li>
	  The amount cannot be higher than [ec_pretty_price [ad_parameter -package_id [ec_id] MaxGiftCertificateAmount ecommerce]]
	</li>"
}

if { $exception_count > 0 } {
    ad_return_complaint $exception_count $exception_text
    ad_script_abort
}

set saved_addresses "
    You can select an address listed below or enter a new address.
    <table border=0 cellspacing=0 cellpadding=20>"

# Present all saved addresses

set address_type "billing"
set referer "gift-certificate-billing"

template::query get_user_addresses addresses multirow "
    select address_id, attn, line1, line2, city, usps_abbrev, zip_code, phone, country_code, full_state_name, phone_time, address_type
    from ec_addresses
    where user_id=:user_id
    and address_type in ('billing')" -eval {

    set row(formatted) [ec_display_as_html [ec_pretty_mailing_address_from_args $row(line1) $row(line2) $row(city) $row(usps_abbrev) $row(zip_code) $row(country_code) \
						$row(full_state_name) $row(attn) $row(phone) $row(phone_time)]]
    set address_id $row(address_id)
    set row(delete) "[export_form_vars address_id certificate_to certificate_from certificate_message amount recipient_email referer]"
    set row(edit) "[export_form_vars address_id address_type certificate_to certificate_from certificate_message amount recipient_email referer]"
    set row(use) "[export_form_vars address_id certificate_to certificate_from certificate_message amount recipient_email]"
}

set hidden_form_vars [export_form_vars address_type certificate_to certificate_from certificate_message amount recipient_email referer]
set title "Completing Your Order"
set context [list $title]
set ec_system_owner [ec_system_owner]

