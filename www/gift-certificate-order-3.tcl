#  www/ecommerce/gift-certificate-order-3.tcl
ad_page_contract {
asks for payment info  
@param certificate_to
@param certificate_from
@param certificate_message
@param amount
@param recipient_email
  @author
  @creation-date
  @cvs-id gift-certificate-order-3.tcl,v 3.2.6.9 2000/08/18 21:46:33 stevenp Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    certificate_to:optional
    certificate_from:optional
    certificate_message:optional
    amount:notnull
    recipient_email:notnull,email
}

ec_redirect_to_https_if_possible_and_necessary

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

if { $amount < [ad_parameter -package_id [ec_id] MinGiftCertificateAmount ecommerce] } {
    incr exception_count
    append exception_text "<li>The amount needs to be at least [ec_pretty_price [ad_parameter -package_id [ec_id] MinGiftCertificateAmount ecommerce]]"
} elseif { $amount > [ad_parameter -package_id [ec_id] MaxGiftCertificateAmount ecommerce] } {
    incr exception_count
    append exception_text "<li>The amount cannot be higher than [ec_pretty_price [ad_parameter -package_id [ec_id] MaxGiftCertificateAmount ecommerce]]"
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

if { $exception_count > 0 } {
    ad_return_complaint $exception_count $exception_text
    return
}



set ec_creditcard_widget [ec_creditcard_widget]
set ec_expires_widget "[ec_creditcard_expire_1_widget] [ec_creditcard_expire_2_widget]"
set zip_code [db_string get_zip_code "select zip_code from ec_addresses where address_id=(select max(address_id) from ec_addresses where user_id=:user_id)" -default ""]
set hidden_form_variables [export_form_vars certificate_to certificate_from certificate_message amount recipient_email]
db_release_unused_handles

ec_return_template
