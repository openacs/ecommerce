#  www/ecommerce/gift-certificate-order-2.tcl
ad_page_contract {
 asks for gift certificate info like message, amount, recipient_email
  @author
  @creation-date
  @cvs-id gift-certificate-order-2.tcl,v 3.2.6.5 2000/08/18 21:46:33 stevenp Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
}

set email ""
set mightbe ""
set user_id [ad_get_user_id]
if {$user_id == 0} {
    set mightbe [ad_get_signed_cookie "ad_user_login"]
    if {![string equal "" $mightbe]} {
        set email [db_string gco_email "
        select email
          from persons, parties
         where person_id = :mightbe
           and person_id = party_id
        " -default ""]
    }
}

ec_redirect_to_https_if_possible_and_necessary

# user must be logged in
# verify_and
set user_id [ad_verify_and_get_user_id]

# wtem@olywa.net, 2001-03-29
# user login rolled into ec_redirect_to_https_if_possible_and_necessary

set currency [ad_parameter -package_id [ec_id] Currency ecommerce]
set minimum_amount [ec_pretty_price [ad_parameter -package_id [ec_id] MinGiftCertificateAmount ecommerce]]
set maximum_amount [ec_pretty_price [ad_parameter -package_id [ec_id] MaxGiftCertificateAmount ecommerce]]


ec_return_template
