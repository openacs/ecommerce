#  www/[ec_url_concat [ec_url] /admin]/products/offer-edit.tcl
ad_page_contract {
  Edit an offer.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id offer-edit.tcl,v 3.1.6.3 2000/08/18 20:23:46 stevenp Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  offer_id:integer,notnull
  product_id:integer,notnull
  retailer_id:integer,notnull
}

ad_require_permission [ad_conn package_id] admin

set product_name [ec_product_name $product_id]

doc_body_append "[ad_admin_header "Edit Retailer Offer on $product_name"]

<h2>Edit Retailer Offer on $product_name</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index.tcl" "Products"] [list "one.tcl?[export_url_vars product_id]" $product_name] "Edit Retailer Offer"]

<hr>
"

set old_retailer_id $retailer_id

doc_body_append "<form method=post action=offer-edit-2>
[export_form_vars offer_id product_id product_name old_retailer_id]

<table>
<tr>
<td>
Retailer
</td>
<td>
<select name=retailer_id>
<option value=\"\">Pick One
"

db_foreach retailer_select "
select retailer_name, retailer_id, city, usps_abbrev
from ec_retailers
order by retailer_name
" {
    if { $retailer_id == $old_retailer_id } {
	doc_body_append "<option value=$retailer_id selected>$retailer_name ($city, $usps_abbrev)\n"
    } else {
	doc_body_append "<option value=$retailer_id>$retailer_name ($city, $usps_abbrev)\n"
    }
}

db_1row offer_select "
select price, shipping, stock_status, shipping_unavailable_p, offer_begins,
       offer_ends, special_offer_p, special_offer_html from ec_offers
where offer_id=:offer_id
"

set currency [ad_parameter -package_id [ec_id] Currency ecommerce]

doc_body_append "</select>
</td>
</tr>
<tr>
<td>Price</td>
<td><input type=text name=price size=6 value=\"$price\"> (in $currency)</td>
</tr>
<tr>
<td>Shipping</td>
<td><input type=text name=shipping size=6 value=\"$shipping\"> (in $currency) 
&nbsp;&nbsp;<b>or</b>&nbsp;&nbsp;
<input type=checkbox name=shipping_unavailable_p value=\"t\""

if { $shipping_unavailable_p == "t" } {
    doc_body_append " checked "
}

doc_body_append ">
Pick Up only
</td>
</tr>
<tr>
<td>Stock Status</td>
<td>[ec_stock_status_widget $stock_status]</td>
</tr>
<tr>
<td>Offer Begins</td>
<td>[ad_dateentrywidget offer_begins $offer_begins]</td>
</tr>
<tr>
<td>Offer Expires</td>
<td>[ad_dateentrywidget offer_ends $offer_ends]</td>
</tr> 
<tr>
<td colspan=2>Is this a Special Offer?
<input type=radio name=special_offer_p value=\"t\""

if { $special_offer_p == "t" } {
    doc_body_append " checked "
}

doc_body_append ">Yes &nbsp; 
<input type=radio name=special_offer_p value=\"f\""

if { $special_offer_p == "f" } {
    doc_body_append " checked "
}

doc_body_append ">No
</td>
</tr>
<tr>
<td>If yes, elaborate:</td>
<td><textarea wrap name=special_offer_html rows=2 cols=40>$special_offer_html</textarea></td>
</tr>
</table>

<center>
<input type=submit value=\"Edit\">
</center>

</form>

[ad_admin_footer]
"
