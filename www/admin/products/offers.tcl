#  www/[ec_url_concat [ec_url] /admin]/products/offers.tcl
ad_page_contract {

  @author
  @creation-date
  @cvs-id offers.tcl,v 3.1.6.3 2000/08/18 20:23:46 stevenp Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  product_id:integer,notnull
}

ad_require_permission [ad_conn package_id] admin

set product_name [ec_product_name $product_id]

proc ec_write_out_one_offer {} {
    uplevel {
	doc_body_append "<li><a href=\"retailer?retailer_id=$retailer_id\">$retailer_name</a><br>
	Price: [ec_message_if_null [ec_pretty_price $price $currency]]<br>
	Shipping: 
	"
	if { $shipping_unavailable_p != "t" } {
	    doc_body_append "[ec_message_if_null [ec_pretty_price $shipping $currency]]<br>"
	} else {
	    doc_body_append "Pick Up<br>"
	}
	doc_body_append "Stock Status: "
	if { ![empty_string_p $stock_status] } {
            doc_body_append [util_memoize "ad_parameter -package_id [ec_id] \"StockMessage[string toupper $stock_status]\"" [ec_cache_refresh]]
	} else {
	    doc_body_append "[ec_message_if_null $stock_status]<br>\n"
	}
	doc_body_append "Offer Begins: [util_AnsiDatetoPrettyDate $offer_begins]<br>
	Offer Expires: [util_AnsiDatetoPrettyDate $offer_ends]<br>
	"
	if { $special_offer_p == "t" } {
	    doc_body_append "Special Offer: $special_offer_html<br>\n"
	}

	if { $deleted_p == "t" } {
	    doc_body_append "<b>This offer is deleted.</b><br>\n"
	} elseif { !$offer_begun_p } {
	    doc_body_append "<b>This offer has not yet begun.</b><br>\n"
	} elseif { $offer_expired_p } {
	    doc_body_append "<b>This offer has expired.</b><br>\n"
	}

	doc_body_append "\[<a href=\"offer-edit?[export_url_vars offer_id product_id product_name retailer_id]\">edit</a> | <a href=\"offer-delete?deleted_p="
	if { $deleted_p == "t" } {
	    doc_body_append "f"
	} else {
	    doc_body_append "t"
	}

	doc_body_append "&[export_url_vars product_id product_name retailer_id]\">"
	
	if { $deleted_p == "t" } {
	    doc_body_append "un"
	}

	# Set audit variables
	# audit_name, id, id_column, return_url, audit_tables, main_tables
	set audit_name "$product_name Offer"
	set id $offer_id
	set id_column "offer_id"
	set return_url "offers.tcl?[export_url_vars product_id product_name]"
	set audit_tables [list ec_offers_audit]	
	set main_tables [list ec_offers]

	doc_body_append "delete</a> | <a href=\"audit?[export_url_vars audit_name id id_column return_url audit_tables main_tables]\">audit trail</a>\]
	<p>
	"
    }
}

doc_body_append "[ad_admin_header "Retailer Offers on $product_name"]

<h2>Retailer Offers on $product_name</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index.tcl" "Products"] [list "one.tcl?[export_url_vars product_id]" $product_name] "Retailer Offers"]

<hr>
<h3>Current Offers</h3>
<ul>
"
set currency [util_memoize {ad_parameter -package_id [ec_id] Currency ecommerce} [ec_cache_refresh]]

db_foreach offers_select "
select o.offer_id, o.retailer_id, r.retailer_name, price, shipping,
       stock_status, special_offer_p, special_offer_html,
       shipping_unavailable_p, offer_begins, offer_ends, o.deleted_p,
       decode(sign(sysdate-offer_begins),1,1,0) as offer_begun_p,
       decode(sign(sysdate-offer_ends),1,1,0) as offer_expired_p
from ec_offers_current o, ec_retailers r
where o.retailer_id=r.retailer_id
and o.product_id=:product_id
order by o.last_modified desc
" {
    ec_write_out_one_offer
} if_no_rows {
    doc_body_append "There are no current offers.\n"
}

doc_body_append "</ul>

<p>

<h3>Add an Offer</h3>

<form method=post action=offer-add>
[export_form_vars product_id]

<table>
<tr>
<td>
Retailer
</td>
<td>
<select name=retailer_id>
<option value=\"\">Pick One
"
db_foreach retailer_select "select retailer_name, retailer_id, decode(reach,'web',url,city || ', ' || usps_abbrev) as location from ec_retailers order by retailer_name" {
    doc_body_append "<option value=$retailer_id>$retailer_name ($location)\n"
}

doc_body_append "</select>
</td>
</tr>
<tr>
<td>Price</td>
<td><input type=text name=price size=6> (in $currency)</td>
</tr>
<tr>
<td>Shipping</td>
<td><input type=text name=shipping size=6> (in $currency) 
&nbsp;&nbsp;<b>or</b>&nbsp;&nbsp;
<input type=checkbox name=shipping_unavailable_p value=\"t\">
Pick Up only
</td>
</tr>
<tr>
<td>Stock Status</td>
<td>[ec_stock_status_widget]</td>
</tr>
<tr>
<td>Offer Begins</td>
<td>[ad_dateentrywidget offer_begins]</td>
</tr>
<tr>
<td>Offer Expires</td>
<td>[ad_dateentrywidget offer_ends now]</td>
</tr> 
<tr>
<td colspan=2>Is this a Special Offer?
<input type=radio name=special_offer_p value=\"t\">Yes &nbsp; 
<input type=radio name=special_offer_p value=\"f\" checked>No
</td>
</tr>
<tr>
<td>If yes, elaborate:</td>
<td><textarea wrap name=special_offer_html rows=2 cols=40></textarea></td>
</tr>
</table>

<p>

<center>
<input type=submit value=\"Add\">
</center>

</form>

<p>

<h3>Non-Current or Deleted Offers</h3>

<ul>
"
set currency [util_memoize {ad_parameter -package_id [ec_id] Currency ecommerce} [ec_cache_refresh]]

db_foreach non_current_offers_select "
select o.offer_id, o.retailer_id, retailer_name, price, shipping,
       stock_status, special_offer_p, special_offer_html,
       shipping_unavailable_p, offer_begins, offer_ends, o.deleted_p,
       decode(sign(sysdate-offer_begins),1,1,0) as offer_begun_p,
       decode(sign(sysdate-offer_ends),1,1,0) as offer_expired_p
from ec_offers o, ec_retailers r
where o.retailer_id=r.retailer_id
    and o.product_id=:product_id
    and (o.deleted_p='t' or o.offer_begins - sysdate > 0 or o.offer_ends - sysdate < 0)
order by o.last_modified desc" {
    ec_write_out_one_offer
} if_no_rows {
    doc_body_append "There are no non-current or deleted offers.\n"
}

db_release_unused_handles

doc_body_append "</ul>

[ad_admin_footer]
"