ad_page_contract {

    Asks for gift certificate info like message, amount, recipient_email

    @author
    @creation-date
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse <bart.teeuwisse@7-sisters.com>
    @revision-date April 2002

} {
}

ec_redirect_to_https_if_possible_and_necessary

# User must be logged in

set user_id [ad_verify_and_get_user_id]

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
            and person_id = party_id" -default ""]
    }
}

set currency [ad_parameter -package_id [ec_id] Currency ecommerce]
set minimum_amount [ec_pretty_price [ad_parameter -package_id [ec_id] MinGiftCertificateAmount ecommerce]]
set maximum_amount [ec_pretty_price [ad_parameter -package_id [ec_id] MaxGiftCertificateAmount ecommerce]]

ad_return_template
