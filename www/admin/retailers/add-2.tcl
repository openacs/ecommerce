#  www/[ec_url_concat [ec_url] /admin]/retailers/add-2.tcl
ad_page_contract {
    This page confirms that the information of new retailer.

  @author
  @creation-date
  @cvs-id add-2.tcl,v 3.1.6.7 2000/09/22 01:34:59 kevin Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    retailer_name
    primary_contact_name
    secondary_contact_name
    primary_contact_info
    secondary_contact_info
    line1
    line2
    city
    usps_abbrev
    zip_code
    phone
    fax
    url
    country_code
    reach
    financing_policy
    return_policy
    price_guarantee_policy
    delivery_policy
    installation_policy
    nexus_states:multiple
}

ad_require_permission [ad_conn package_id] admin

# I think retailer_name, line1, city, usps_abbrev, zip_code, phone,
# country_code, and reach should be required

set possible_error_list [list [list retailer_name "the name of the retailer"] [list line1 "the address"] [list city "the city"] [list usps_abbrev "the state"] [list zip_code "the zip code"] [list phone "the phone number"] [list country_code "the country"] [list reach "the reach"] ]

set exception_count 0
set exception_text ""

foreach possible_error $possible_error_list {
    if { ![info exists [lindex $possible_error 0]] || [empty_string_p [set [lindex $possible_error 0]]] } {
	incr exception_count
	append exception_text "<li>You forgot to enter [lindex $possible_error 1]."
    }
}

if { $exception_count > 0 } {
    ad_return_complaint $exception_count $exception_text
    return
}

set page_html "[ad_admin_header "Confirm New Retailer"]

<h2>Confirm New Retailer</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index.tcl" "Retailers"] "Add Retailer"]

<hr>
<h3>Please confirm that the information below is correct:</h3>

<blockquote>
<table>
<tr>
<td>
Retailer Name:
</td>
<td>
$retailer_name
</td>
</tr>
<tr>
<td>
Primary Contact:
</td>
<td>
$primary_contact_name<br>
[bboard_convert_plaintext_to_html $primary_contact_info]
</td>
</tr>
<tr>
<td>
Secondary Contact:
</td>
<td>
$secondary_contact_name<br>
[bboard_convert_plaintext_to_html $secondary_contact_info]
</td>
</tr>
<tr>
<td>
Address
</td>
<td>
"

append page_html "[bboard_convert_plaintext_to_html [ad_pretty_mailing_address_from_args  $line1 $line2 $city $usps_abbrev $zip_code $country_code]]
</td>
</tr>
<tr>
<td>
Phone
</td>
<td>
$phone
</td>
</tr>
<tr>
<td>
Fax
</td>
<td>
$fax
</td>
</tr>
<tr>
<td>
URL
</td>
<td><a href=\"$url\">$url</a></td>
</tr>
<tr>
<td>
Reach
</td>
<td>
$reach
</td>
</tr>
<tr>
<td>
Nexus States
</td>
<td>
$nexus_states
</td>
</tr>
<tr>
<td>
Financing
</td>
<td>
[bboard_convert_plaintext_to_html $financing_policy]
</td>
</tr>
<tr>
<td>
Return Policy
</td>
<td>
[bboard_convert_plaintext_to_html $return_policy]
</td>
</tr>
<tr>
<td>
Price Guarantee Policy
</td>
<td>
[bboard_convert_plaintext_to_html $price_guarantee_policy]
</td>
</tr>
<tr>
<td>
Delivery
</td>
<td>
[bboard_convert_plaintext_to_html $delivery_policy]
</td>
</tr>
<tr>
<td>
Installation
</td>
<td>
[bboard_convert_plaintext_to_html $installation_policy]
</td>
</tr>
</table>
</blockquote>

<form method=post action=add-3>
"

set retailer_id [db_nextval ec_retailer_sequence]

append page_html "[export_form_vars retailer_id retailer_name primary_contact_name secondary_contact_name primary_contact_info secondary_contact_info line1 line2 city usps_abbrev zip_code phone fax url country_code reach nexus_states financing_policy return_policy price_guarantee_policy delivery_policy installation_policy]

<center>
<input type=submit value=\"Confirm\">
</center>
</form>

[ad_admin_footer]
"




doc_return  200 text/html $page_html