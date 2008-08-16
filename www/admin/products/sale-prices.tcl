ad_page_contract {
    Let's site admin define a special time-limited price for an item.

    @author Eve Andersson (eveander@arsdigita.com) 
    @creation-date June 1999
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
} {
  product_id:integer,notnull
  price:optional
}

ad_require_permission [ad_conn package_id] admin

set product_name [ec_product_name $product_id]
set title "Sale Prices for $product_name"
set context [list [list index Products] $title]


proc ec_write_out_one_sale {} {
    uplevel {
	doc_body_append "<li>$sale_name<br>
	Price: [ec_message_if_null [ec_pretty_price $sale_price $currency]]<br>
	Sale Begins: [util_AnsiDatetoPrettyDate [ec_date_with_time_stripped $sale_begins]] [lindex [split $sale_begins " "] 1]<br>
	Sale Ends: [util_AnsiDatetoPrettyDate [ec_date_with_time_stripped $sale_ends]] [lindex [split $sale_ends " "] 1]<br>
	[ec_decode $offer_code "" "" "Offer Code: $offer_code<br>"]
	"
	if { !$sale_begun_p } {
	    doc_body_append "<b>This sale has not yet begun.</b><br>\n"
	} elseif { $sale_expired_p } {
	    doc_body_append "<b>This sale has ended.</b><br>\n"
	}

	doc_body_append "\[<a href=\"sale-price-edit?[export_url_vars sale_price_id product_id product_name]\">edit</a>[ec_decode $sale_expired_p "0" " | <a href=\"sale-price-expire?[export_url_vars sale_price_id product_id product_name]\">expire now</a>" ""]"
	
	# Set audit variables
	# audit_name, id, id_column, return_url, audit_tables, main_tables
	set audit_name "$product_name Sale"
	set audit_id $sale_price_id
	set audit_id_column "sale_price_id"
	set return_url "sale-prices.tcl?[export_url_vars product_id product_name]"
	set audit_tables [list ec_sale_prices_audit]	
	set main_tables [list ec_sale_prices]

	doc_body_append " | <a href=\"[ec_url_concat [ec_url] /admin]/audit?[export_url_vars audit_name audit_id audit_id_column return_url audit_tables main_tables]\">audit trail</a>\]
	<p>
	"
    }
}

set currency [parameter::get -package_id [ec_id] -parameter Currency -default "USD"]

if {[info exists price]} {
    set price_html [ec_pretty_price $price $currency]
}

set sale_price_counter 0
set current_sales_select_html ""
db_foreach current_sales_select "select sale_price_id, sale_name, sale_price, offer_code, to_char(sale_begins,'YYYY-MM-DD HH24:MI:SS') as sale_begins, to_char(sale_ends,'YYYY-MM-DD HH24:MI:SS') as sale_ends, decode(sign(sysdate-sale_begins),1,1,0) as sale_begun_p, decode(sign(sysdate-sale_ends),1,1,0) as sale_expired_p
from ec_sale_prices_current
where product_id=:product_id
order by last_modified desc" {
    incr sale_price_counter
    append current_sales_select_html [ec_write_out_one_sale]
}

set export_form_vars_html [export_form_vars product_id product_name price]

set nc_sale_price_counter 0
set non_current_sales_select_html ""
db_foreach non_current_sales_select "select sale_price_id, sale_name, sale_price, offer_code, to_char(sale_begins,'YYYY-MM-DD HH24:MI:SS') as sale_begins, to_char(sale_ends,'YYYY-MM-DD HH24:MI:SS') as sale_ends, decode(sign(sysdate-sale_begins),1,1,0) as sale_begun_p, decode(sign(sysdate-sale_ends),1,1,0) as sale_expired_p
from ec_sale_prices
where product_id=:product_id
and (sale_begins - sysdate > 0 or sale_ends - sysdate < 0)
order by last_modified desc" {
    incr nc_sale_price_counter
    append non_current_sales_select_html [ec_write_out_one_sale]
}

set sale_begins_widget_html "[ad_dateentrywidget sale_begins] [ec_time_widget sale_begins "00:00:00"]"
set sale_ends_widget_html "[ad_dateentrywidget sale_ends] [ec_time_widget sale_ends "23:59:59"]"







