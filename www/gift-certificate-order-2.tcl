ad_page_contract {

    Asks for gift certificate info like message, amount, recipient_email

    @author
    @creation-date
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @revision-date April 2002

} {
}

ec_redirect_to_https_if_possible_and_necessary

# User must be logged in

set user_id [ad_conn user_id]

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
set context_bar [template::adp_parse [acs_root_dir]/packages/[ad_conn package_key]/www/contextbar [list context_addition [list "Your Gift Certificate Order"]]]
set ec_system_owner [ec_system_owner]

ad_return_template
