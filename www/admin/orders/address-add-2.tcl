ad_page_contract {

    Confirm shipping address.

    @author Eve Andersson (eveander@arsdigita.com)
    @creation-date Summer 1999
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @revision-date April 2002

} {
    order_id:integer,notnull
    creditcard_id:integer,optional
    attn
    line1
    line2
    city
    {usps_abbrev ""}
    {full_state_name ""}
    zip_code
    {country_code "US"}
    phone
    phone_time
}

ad_require_permission [ad_conn package_id] admin

set title "Confirm Shipping Address"
set context [list [list index "Orders / Shipments / Refunds"] $title]

set export_entire_form_html [export_entire_form]
set pretty_mailing_address_html "[ec_display_as_html [ec_pretty_mailing_address_from_args $line1 $line2 $city $usps_abbrev $zip_code $country_code $full_state_name $attn $phone $phone_time]]"
