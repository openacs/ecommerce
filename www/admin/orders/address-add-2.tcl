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

doc_body_append "
    [ad_admin_header "Confirm Shipping Address"]

    <h2>Confirm Shipping Address</h2>

    [ad_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index" "Orders"] [list "one?[export_url_vars order_id]" "One Order"] "Confirm Shipping Address"]

    <hr>
    <p>Please confirm new address:</p>
    <blockquote>"

doc_body_append "
      [ec_display_as_html [ec_pretty_mailing_address_from_args $line1 $line2 $city $usps_abbrev $zip_code $country_code $full_state_name $attn $phone $phone_time]]
    </blockquote>
    <form method=post action=address-add-3>
      [export_entire_form]
      <center>
        <input type=submit value=\"Confirm\">
      </center>
    </form>
    [ad_admin_footer]"
