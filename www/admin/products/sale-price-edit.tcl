ad_page_contract {

    Edit a sale price.

    @author Eve Andersson (eveander@arsdigita.com)
    @creation-date Summer 1999
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @revision-date April 2002

} {
    product_id:integer,notnull
    sale_price_id:integer,notnull
}

ad_require_permission [ad_conn package_id] admin

set product_name [ec_product_name $product_id]

doc_body_append "
    [ad_admin_header "Edit Sale Price for $product_name"]

    <h2>Edit Sale Price for $product_name</h2>

    [ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index.tcl" "Products"] [list "one.tcl?[export_url_vars product_id]" $product_name] "Edit Sale Price"]

    <hr>
    <form method=post action=sale-price-edit-2>
    
    [export_form_vars product_id product_name sale_price_id]"

db_1row sale_price_select "
    select sale_price, to_char(sale_begins,'YYYY-MM-DD HH24:MI:SS') as sale_begins, to_char(sale_ends,'YYYY-MM-DD HH24:MI:SS') as sale_ends, sale_name, offer_code 
    from ec_sale_prices
    where sale_price_id = :sale_price_id"

doc_body_append "
    <table>
	<tr>
	  <td>Sale Price</td>
	  <td><input type=text name=sale_price size=6 value=\"$sale_price\"> (in [ad_parameter -package_id [ec_id] Currency ecommerce])</td>
	</tr>
	<tr>
	  <td>Name</td>
	  <td><input type=text name=sale_name size=35 maxlength=30 value=\"[ad_quotehtml $sale_name]\"> (like Special Offer or Introductory Price or Sale Price)</td>
	</tr>
	<tr>
	  <td>Sale Begins</td>
	  <td>[ad_dateentrywidget sale_begins [ec_date_with_time_stripped $sale_begins]] [ec_time_widget sale_begins [lindex [split $sale_begins " "] 1]]</td>
	</tr>
	<tr>
	  <td>Sale Ends</td>
	  <td>[ad_dateentrywidget sale_ends [ec_date_with_time_stripped $sale_ends]] [ec_time_widget sale_ends [lindex [split $sale_ends " "] 1]]</td>
	</tr>
	<tr>
	  <td>Offer Code</td>
	  <td><input type=radio name=\"offer_code_needed\" value=\"no\" [ec_decode $offer_code "" "checked" ""]> None needed<br>
	    <input type=radio name=\"offer_code_needed\" value=\"yes_supplied\" [ec_decode $offer_code "" "" "checked"]> Require this code: 
	    <input type=text name=\"offer_code\" size=10 maxlength=20 value=\"$offer_code\"><br>
	    <input type=radio name=\"offer_code_needed\" value=\"yes_generate\"> Please generate a [ec_decode $offer_code "" "" "new "]code
	  </td>
	</tr>
    </table>

    <center>
      <input type=submit value=\"Submit\">
    </center>

    </form>

    [ad_admin_footer] "
