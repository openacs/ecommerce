ad_page_contract {
    The user is redirected to this page from
    gift-certificate-finalize-order.tcl if their gift certificate
    order has succeeded. This page displays a thank you message.

    @author
    @creation-date
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @revision-date April 2002

} {
}

set home_page "[ec_insecure_location][ec_url]index"
set title "Thank You For Your Gift Certificate Order"
set context [list $title]
set ec_system_owner [ec_system_owner]

ad_return_template
