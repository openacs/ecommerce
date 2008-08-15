#  www/[ec_url_concat [ec_url] /admin]/products/offers.tcl
ad_page_contract {

  @author
  @creation-date
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  product_id:integer,notnull
}

ad_require_permission [ad_conn package_id] admin

set product_name [ec_product_name $product_id]

proc ec_write_out_one_offer {} {
    uplevel {
	append doc_body "<li><a href=\"retailer?retailer_id=$retailer_id\">$retailer_name</a><br>
	Price: [ec_message_if_null [ec_pretty_price $price $currency]]<br>
	Shipping: 
	"
	if { $shipping_unavailable_p != "t" } {
	    append doc_body "[ec_message_if_null [ec_pretty_price $shipping $currency]]<br>"
	} else {
	    append doc_body "Pick Up<br>"
	}
	append doc_body "Stock Status: "
	if { ![empty_string_p $stock_status] } {
            append doc_body [util_memoize "ad_parameter -package_id [ec_id] \"StockMessage[string toupper $stock_status]\"" [ec_cache_refresh]]
	} else {
	    append doc_body "[ec_message_if_null $stock_status]<br>\n"
	}
	append doc_body "Offer Begins: [util_AnsiDatetoPrettyDate $offer_begins]<br>
	Offer Expires: [util_AnsiDatetoPrettyDate $offer_ends]<br>
	"
	if { $special_offer_p == "t" } {
	    append doc_body "Special Offer: $special_offer_html<br>\n"
	}

	if { $deleted_p == "t" } {
	    append doc_body "<b>This offer is deleted.</b><br>\n"
	} elseif { !$offer_begun_p } {
	    append doc_body "<b>This offer has not yet begun.</b><br>\n"
	} elseif { $offer_expired_p } {
	    append doc_body "<b>This offer has expired.</b><br>\n"
	}

	append doc_body "\[<a href=\"offer-edit?[export_url_vars offer_id product_id product_name retailer_id]\">edit</a> | <a href=\"offer-delete?deleted_p="
	if { $deleted_p == "t" } {
	    append doc_body "f"
	} else {
	    append doc_body "t"
	}

	append doc_body "&[export_url_vars product_id product_name retailer_id]\">"
	
	if { $deleted_p == "t" } {
	    append doc_body "un"
	}

	# Set audit variables
	# audit_name, id, id_column, return_url, audit_tables, main_tables
	set audit_name "$product_name Offer"
	set id $offer_id
	set id_column "offer_id"
	set return_url "offers.tcl?[export_url_vars product_id product_name]"
	set audit_tables [list ec_offers_audit]	
	set main_tables [list ec_offers]

	append doc_body "delete</a> | <a href=\"audit?[export_url_vars audit_name id id_column return_url audit_tables main_tables]\">audit trail</a>\]
	<p>
	"
    }
return $doc_body
}

set title "Retailer Offers on $product_name"
set context [list [list index Products] $title]

set currency [parameter::get -package_id [ec_id] -parameter Currency -default "USD"]

set no_offers 0
set offers_select_html ""
db_foreach offers_select "
select o.offer_id, o.retailer_id, r.retailer_name, price, shipping,
       stock_status, special_offer_p, special_offer_html,
       shipping_unavailable_p, offer_begins, offer_ends, o.deleted_p,
       decode(sign(sysdate-offer_begins),1,1,0) as offer_begun_p,
       decode(sign(sysdate-offer_ends),1,1,0) as offer_expired_p
from ec_offers_current o, ec_retailers r
where o.retailer_id=r.retailer_id
and o.product_id=:product_id
order by o.last_modified desc" {
    append offers_select_html ec_write_out_one_offer
} if_no_rows {
     set no_offers 1
}

set export_product_id_html [export_form_vars product_id]

set retailer_select_html ""
db_foreach retailer_select "select retailer_name, retailer_id, decode(reach,'web',url,city || ', ' || usps_abbrev) as location from ec_retailers order by retailer_name" {
    append retailer_select_html "<option value=$retailer_id>$retailer_name ($location)\n"
}

set stock_status_html [ec_stock_status_widget]
set offer_begins_html [ad_dateentrywidget offer_begins]
set offer_expires_html [ad_dateentrywidget offer_ends now]

set non_current_offers_select_html ""
set no_non_current_offers 0
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
    append non_current_offers_select_html ec_write_out_one_offer
} if_no_rows {
    set no_non_current_offers 1
}

db_release_unused_handles
