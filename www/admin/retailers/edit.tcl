#  www/[ec_url_concat [ec_url] /admin]/retailers/edit.tcl
ad_page_contract {
    @param retailer_id the ID of the retailer

  @author
  @creation-date
  @cvs-id edit.tcl,v 3.1.6.5 2000/09/22 01:35:00 kevin Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    retailer_id
}

ad_require_permission [ad_conn package_id] admin

set page_html "[ad_admin_header "Edit Retailer"]

<h2>Edit Retailer</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index.tcl" "Retailers"] "Edit Retailer"]

<hr>

<p>
"


db_1row get_retailer_details "
select retailer_id ,
    retailer_name,
    primary_contact_name,
    secondary_contact_name,
    primary_contact_info,
    secondary_contact_info,
    line1,
    line2,
    city ,
    usps_abbrev,
    zip_code,
    phone,
    fax,
    url,
    country_code,
    reach,
    nexus_states,
    financing_policy,
    return_policy,
    
    price_guarantee_policy,
    delivery_policy,
    installation_policy
from ec_retailers 
where retailer_id=:retailer_id"

db_release_unused_handles

append page_html "<form method=post action=edit-2>
[export_form_vars retailer_id]
<table>
<tr>
<td valign=top>Retailer Name</td>
<td valign=top><input type=text name=retailer_name size=30 value=\"[ad_quotehtml $retailer_name]\"></td>
</tr>
<tr>
<td valign=top>Primary Contact</td>
<td valign=top>

  <table>
  <tr>
  <td valign=top>Name</td>
  <td valign=top><input type=text name=primary_contact_name size=30 value=\"[ad_quotehtml $primary_contact_name]\"><br></td>
  </tr>
  <tr>
  <td valign=top>Contact Info</td>
  <td valign=top><textarea wrap name=primary_contact_info rows=4 cols=30>$primary_contact_info</textarea></td>
  </tr>
  </table>

</td>
</tr>
<tr>
<td valign=top>Secondary Contact</td>
<td valign=top>

  <table>
  <tr>
  <td valign=top>Name</td>
  <td valign=top><input type=text name=secondary_contact_name size=30 value=\"[ad_quotehtml $secondary_contact_name]\"><br></td>
  </tr>
  <tr>
  <td valign=top>Contact Info</td>
  <td valign=top><textarea wrap name=secondary_contact_info rows=4 cols=30>$secondary_contact_info</textarea></td>
  </tr>
  </table>

</td>
</tr>
<tr>
<td valign=top>Address</td>
<td valign=top><input type=text name=line1 size=30 value=\"[ad_quotehtml $line1]\"><br>
<input type=text name=line2 size=30 value=\"[ad_quotehtml $line2]\"></td>
</tr>
<tr>
<td valign=top>City</td>
<td valign=top><input type=text name=city size=15 value=\"[ad_quotehtml $city]\">
State [state_widget $usps_abbrev]
Zip <input type=text name=zip_code size=5 value=\"[ad_quotehtml $zip_code]\">
</td>
</tr>
<tr>
<td valign=top>Country</td>
<td valign=top>[country_widget "$country_code" "country_code" ""]</td>
</tr>
<tr>
<td valign=top>Phone</td>
<td valign=top><input type=text name=phone size=14 value=\"[ad_quotehtml $phone]\"></td>
</tr>
<tr>
<td valign=top>Fax</td>
<td valign=top><input type=text name=fax size=14 value=\"[ad_quotehtml $fax]\"></td>
</tr>
<tr>
<td valign=top>URL</td>
<td valign=top><input type=text name=url size=25 value=\"[ad_quotehtml $url]\"></td>
</tr>
<tr>
<td valign=top>Reach</td>
<td valign=top>[ec_reach_widget $reach]</td>
</tr>
<tr>
<td valign=top>Nexus States</td>
<td valign=top>[ec_multiple_state_widget "$nexus_states" nexus_states]</td>
</tr>
<tr>
<td valign=top>Financing</td>
<td valign=top><textarea wrap name=financing_policy rows=4 cols=50>$financing_policy</textarea></td>
</tr>
<tr>
<td valign=top>Return Policy</td>
<td valign=top><textarea wrap name=return_policy rows=4 cols=50>$return_policy</textarea></td>
</tr>
<tr>
<td valign=top>Price Guarantee Policy</td>
<td valign=top><textarea wrap name=price_guarantee_policy rows=4 cols=50>$price_guarantee_policy</textarea></td>
</tr>
<tr>
<td valign=top>Delivery</td>
<td valign=top><textarea wrap name=delivery_policy rows=4 cols=50>$delivery_policy</textarea></td>
</tr>
<tr>
<td valign=top>Installation</td>
<td valign=top><textarea wrap name=installation_policy rows=4 cols=50>$installation_policy</textarea></td>
</tr>
</table>

<p>

<center>
<input type=submit value=\"Continue\">
</center>
</form>
[ad_admin_footer]
"


doc_return  200 text/html $page_html