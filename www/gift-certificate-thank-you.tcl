ad_page_contract {
    The user is redirected to this page from
    gift-certificate-finalize-order.tcl if their gift certificate
    order has succeeded. This page displays a thank you message.

    @author
    @creation-date
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse <bart.teeuwisse@7-sisters.com>
    @revision-date April 2002

} {
}

set home_page "[ec_insecure_location][ec_url]index"
set context_bar [template::adp_parse [acs_root_dir]/packages/[ad_conn package_key]/www/contextbar [list context_addition [list "Thank You For Your Gift Certificate Order"]]]
set ec_system_owner [ec_system_owner]

ad_return_template
