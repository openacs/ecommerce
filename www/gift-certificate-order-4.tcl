#  www/ecommerce/gift-certificate-order-4.tcl
ad_page_contract {
 dispays order summary
  @author
  @creation-date
  @cvs-id gift-certificate-order-4.tcl,v 3.2.6.6 2000/08/18 21:46:33 stevenp Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    certificate_to
    certificate_from
    certificate_message
    amount
    recipient_email:notnull,email
    creditcard_number
    creditcard_type
    creditcard_expire_1
    creditcard_expire_2
    billing_zip_code
}

#

ec_redirect_to_https_if_possible_and_necessary

# get rid of spaces and dashes
regsub -all -- "-" $creditcard_number "" creditcard_number
regsub -all " " $creditcard_number "" creditcard_number

# user must be logged in
set user_id [ad_verify_and_get_user_id]

# wtem@olywa.net, 2001-03-29
# user login rolled into ec_redirect_to_https_if_possible_and_necessary

# error checking

set exception_count 0
set exception_text ""

if { [string length $certificate_message] > 200 } {
    incr exception_count
    append exception_text "<li>The message you entered was too long.  It needs to contain fewer than 200 characters (the current length is [string length $certificate_message] characters)."
} 
if { [string length $certificate_to] > 100 } {
    incr exception_count
    append exception_text "<li>What you entered in the \"To\" field is too long.  It needs to contain fewer than 100 characters (the current length is [string length $certificate_to] characters)."
} 
if { [string length $certificate_from] > 100 } {
    incr exception_count
    append exception_text "<li>What you entered in the \"From\" field is too long.  It needs to contain fewer than 100 characters (the current length is [string length $certificate_from] characters)."
} 
if { [string length $recipient_email] > 100 } {
    incr exception_count
    append exception_text "<li>The recipient email address you entered is too long.  It needs to contain fewer than 100 characters (the current length is [string length $recipient_email] characters)."
}

if { $amount < [util_memoize {ad_parameter -package_id [ec_id] MinGiftCertificateAmount ecommerce} [ec_cache_refresh]] } {
    incr exception_count
    append exception_text "<li>The amount needs to be at least [ec_pretty_price [util_memoize {ad_parameter -package_id [ec_id] MinGiftCertificateAmount ecommerce} [ec_cache_refresh]]]"
} elseif { $amount > [util_memoize {ad_parameter -package_id [ec_id] MaxGiftCertificateAmount ecommerce} [ec_cache_refresh]] } {
    incr exception_count
    append exception_text "<li>The amount cannot be higher than [ec_pretty_price [util_memoize {ad_parameter -package_id [ec_id] MaxGiftCertificateAmount ecommerce} [ec_cache_refresh]]]"
}

#  if { [empty_string_p $recipient_email] } {
#      incr exception_count
#      append exception_text "<li>You forgot to specify the recipient's email address (we need it so we can send them their gift certificate!)"
#  } elseif {![philg_email_valid_p $recipient_email]} {
#      incr exception_count
#      append exception_text "<li>The recipient's email address that you typed doesn't look right to us.  Examples of valid email addresses are 
#  <ul>
#  <li>Alice1234@aol.com
#  <li>joe_smith@hp.com
#  <li>pierre@inria.fr
#  </ul>
#  "
#  }

if { [regexp {[^0-9]} $creditcard_number] } {
    # I've already removed spaces and dashes, so only numbers should remain
    incr exception_count
    append exception_text "<li> Your credit card number contains invalid characters."
}

if { ![info exists creditcard_type] || [empty_string_p $creditcard_type] } {
    incr exception_count
    append exception_text "<li> You forgot to enter your credit card type."
}

# make sure the credit card type is right & that it has the right number
# of digits
# set additional_count_and_text [ec_creditcard_precheck $creditcard_number $creditcard_type]

# set exception_count [expr $exception_count + [lindex $additional_count_and_text 0]]
# append exception_text [lindex $additional_count_and_text 1]

if { ![info exists creditcard_expire_1] || [empty_string_p $creditcard_expire_1] || ![info exists creditcard_expire_2] || [empty_string_p $creditcard_expire_2] } {
    incr exception_count
    append exception_text "<li> Please enter your full credit card expiration date (month and year)"
}

if { $exception_count > 0 } {
    ad_return_complaint $exception_count $exception_text
    return
}



set gift_certificate_id [db_string get_gc_id "select ec_gift_cert_id_sequence.nextval from dual"]
set user_email [db_string get_email_for_user "select email from cc_users where user_id=:user_id"]

set hidden_form_variables [export_form_vars certificate_to certificate_from certificate_message amount recipient_email creditcard_number creditcard_type creditcard_expire_1 creditcard_expire_2 billing_zip_code gift_certificate_id]

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
db_release_unused_handles
ec_return_template

