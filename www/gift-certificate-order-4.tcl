ad_page_contract {

    Dispays order summary

    @author
    @creation-date
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @revision-date April 2002

} {
    address_id
    certificate_to
    certificate_from
    certificate_message
    amount
    recipient_email:notnull,email
    creditcard_number
    creditcard_type
    creditcard_expire_1
    creditcard_expire_2
}

ec_redirect_to_https_if_possible_and_necessary

# Get rid of spaces and dashes

regsub -all -- "-" $creditcard_number "" creditcard_number
regsub -all " " $creditcard_number "" creditcard_number

# User must be logged in

set user_id [ad_verify_and_get_user_id]

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
	  What you entered in the \"From\" field is too long.  It needs to contain fewer than 100 characters (the current length is [string length $certificate_from] characters).
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

if { [regexp {[^0-9]} $creditcard_number] } {

    # I've already removed spaces and dashes, so only numbers should remain

    incr exception_count
    append exception_text "
	<li>
	  Your credit card number contains invalid characters.
	</li>"
}

if { ![info exists creditcard_type] || [empty_string_p $creditcard_type] } {
    incr exception_count
    append exception_text "
	<li>
	  You forgot to enter your credit card type.
	</li>"
}

# Make sure the credit card type is right & that it has the right
# number of digits 

set additional_count_and_text [ec_creditcard_precheck $creditcard_number $creditcard_type]
set exception_count [expr $exception_count + [lindex $additional_count_and_text 0]]
append exception_text [lindex $additional_count_and_text 1]

if { ![info exists creditcard_expire_1] || [empty_string_p $creditcard_expire_1] || ![info exists creditcard_expire_2] || [empty_string_p $creditcard_expire_2] } {
    incr exception_count
    append exception_text "
	<li>
	  Please enter your full credit card expiration date (month and year)
	</li>"
}

if { $exception_count > 0 } {
    ad_return_complaint $exception_count $exception_text
    return
}

set gift_certificate_id [db_nextval ec_gift_cert_id_sequence]
set user_email [db_string get_email_for_user "
    select email 
    from cc_users 
    where user_id=:user_id"]

set hidden_form_variables [export_form_vars address_id certificate_to certificate_from certificate_message amount recipient_email creditcard_number creditcard_type \
			       creditcard_expire_1 creditcard_expire_2 billing_address gift_certificate_id]

if { ![empty_string_p $certificate_to] } {
    set to_row "<tr><td><b>To:</b></td><td>$certificate_to</td></tr>"
} else {
    set to_row ""
}

if { ![empty_string_p $certificate_from] } {
    set from_row "<tr><td><b>From:</b></td><td>$certificate_from</td></tr>"
} else {
    set from_row ""
}

if { ![empty_string_p $certificate_message] } {
    set message_row "<tr><td valign=top><b>Message:</b></td><td>[ec_display_as_html $certificate_message]</td></tr>"
} else {
    set message_row ""
}

set formatted_amount [ec_pretty_price $amount]
set zero_in_the_correct_currency [ec_pretty_price 0]
set context_bar [template::adp_parse [acs_root_dir]/packages/[ad_conn package_key]/www/contextbar [list context_addition [list "Please Confirm Your Gift Certificate Order"]]]
set ec_system_owner [ec_system_owner]
db_release_unused_handles
