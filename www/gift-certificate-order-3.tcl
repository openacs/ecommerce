ad_page_contract {

    Asks for payment info.

    @param address_id
    @param certificate_to
    @param certificate_from
    @param certificate_message
    @param amount
    @param recipient_email

    @author
    @creation-date
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse <bart.teeuwisse@7-sisters.com>
    @revision-date April 2002

} {
    address_id
    certificate_to
    certificate_from
    certificate_message
    amount:notnull
    recipient_email:notnull,email
}

ec_redirect_to_https_if_possible_and_necessary

# User must be logged in

set user_id [ad_verify_and_get_user_id]
if {$user_id == 0} {
    set return_url "[ad_conn url]"
    ad_returnredirect "/register?[export_url_vars return_url]"
    ad_script_abort
}

set ec_creditcard_widget [ec_creditcard_widget]
set ec_expires_widget "[ec_creditcard_expire_1_widget] [ec_creditcard_expire_2_widget]"
set hidden_form_variables [export_form_vars address_id certificate_to certificate_from certificate_message amount recipient_email]
set context_bar [template::adp_parse [acs_root_dir]/packages/[ad_conn package_key]/www/contextbar [list context_addition [list "Payment Info"]]]
set ec_system_owner [ec_system_owner]

db_release_unused_handles
