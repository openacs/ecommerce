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

set currency [ad_parameter -package_id [ec_id] Currency ecommerce]

doc_body_append "[ad_admin_header "Sale Prices for $product_name"]

<h2>Sale Price for $product_name</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index.tcl" "Products"] [list "one.tcl?[export_url_vars product_id]" "One"] "Sale Prices"]

<hr>
"
if {[info exists price]} {
    doc_body_append "
	<h3>Regular Price</h3>
	<blockquote>
	  Regular: [ec_pretty_price $price $currency]
	</blockquote>"
}
doc_body_append "
<h3>Current Sale Prices</h3>
<ul>
"

set sale_price_counter 0
db_foreach current_sales_select "select sale_price_id, sale_name, sale_price, offer_code, to_char(sale_begins,'YYYY-MM-DD HH24:MI:SS') as sale_begins, to_char(sale_ends,'YYYY-MM-DD HH24:MI:SS') as sale_ends, decode(sign(sysdate-sale_begins),1,1,0) as sale_begun_p, decode(sign(sysdate-sale_ends),1,1,0) as sale_expired_p
from ec_sale_prices_current
where product_id=:product_id
order by last_modified desc" {
    incr sale_price_counter
    ec_write_out_one_sale
}

if { $sale_price_counter == 0 } {
    doc_body_append "There are no current sale prices.\n"
}

doc_body_append "</ul>

<p>

<h3>Add a Sale Price</h3>

<blockquote>

<form method=post action=sale-price-add>
[export_form_vars product_id product_name price]

<table>
<tr>
<td>Sale Price</td>
<td><input type=text name=sale_price size=6> (in $currency)</td>
</tr>
<tr>
<td>Name</td>
<td><input type=text name=sale_name size=15> (like Special Offer or Introductory Price or Sale Price)</td>
</tr>
<tr>
<td>Sale Begins</td>
<td>[ad_dateentrywidget sale_begins] [ec_time_widget sale_begins "00:00:00"]</td>
</tr>
<tr>
<td>Sale Ends</td>
<td>[ad_dateentrywidget sale_ends] [ec_time_widget sale_ends "23:59:59"]</td>
</tr>
<tr>
<td valign=top>Offer Code</td>
<td valign=top><input type=radio name=\"offer_code_needed\" value=\"no\" checked> None needed<br>
<input type=radio name=\"offer_code_needed\" value=\"yes_supplied\"> Require this code: 
<input type=text name=\"offer_code\" size=10 maxlength=20><br>
<input type=radio name=\"offer_code_needed\" value=\"yes_generate\"> Please generate a code
</td>
</tr>
</table>

<p>

<center>
<input type=submit value=\"Add\">
</center>

</form>

</blockquote>

<p>

<h3>Old or Yet-to-Come Sale Prices</h3>

<ul>
"
set currency [ad_parameter -package_id [ec_id] Currency ecommerce]


set sale_price_counter 0

db_foreach non_current_sales_select "select sale_price_id, sale_name, sale_price, offer_code, to_char(sale_begins,'YYYY-MM-DD HH24:MI:SS') as sale_begins, to_char(sale_ends,'YYYY-MM-DD HH24:MI:SS') as sale_ends, decode(sign(sysdate-sale_begins),1,1,0) as sale_begun_p, decode(sign(sysdate-sale_ends),1,1,0) as sale_expired_p
from ec_sale_prices
where product_id=:product_id
and (sale_begins - sysdate > 0 or sale_ends - sysdate < 0)
order by last_modified desc" {
    incr sale_price_counter
    ec_write_out_one_sale
}

if { $sale_price_counter == 0 } {
    doc_body_append "There are no non-current sale prices.\n"
}

doc_body_append "</ul>

To let customers take advantage a sale price that requires an offer_code, send them to the URL
of the product display page with <code>&amp;offer_code=<i>offer_code</i></code>
appended to the URL.
[ad_admin_footer]
"







