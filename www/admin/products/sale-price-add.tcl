#  www/[ec_url_concat [ec_url] /admin]/products/sale-price-add.tcl
ad_page_contract {
  Add a sale price.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id sale-price-add.tcl,v 3.1.6.3 2000/08/18 20:23:47 stevenp Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  product_id:integer,notnull
    {price:optional ""}
  sale_price:notnull
  {sale_name "Sale Price"}
  sale_begins:array,date
  sale_ends:array,date
  offer_code_needed
  offer_code:optional
}

ad_require_permission [ad_conn package_id] admin

if {![regexp {^[0-9|.]+$} $sale_price match ]} {
    ad_return_complaint 1 "The price you entered is not a valid number."
    return
} 

if {[regexp {^[.]$}  $sale_price match ]} {
    ad_return_complaint 1 "<li>Please enter a number for price."
    return
}
# If a regular price exists, compare it with sale price

if {![empty_string_p $price]} {
    if {$price <= $sale_price} {
	ad_return_complaint 1 "<li>Please enter a sale price less than the regular price."
	return
    }
}

page_validation {
#  ec_date_widget_validate sale_begins
} {
  ec_time_widget_validate sale_begins
} {
#  ec_date_widget_validate sale_ends
} {
  ec_time_widget_validate sale_ends
}

if { [empty_string_p [ec_datetime_text sale_begins]] } {
  ad_return_complaint 1 "You forgot to enter the time that the sale begins."
  return
}

if { [empty_string_p [ec_datetime_text sale_ends]] } {
  ad_return_complaint 1 "You forgot to enter the time that the sale begins."
  return
}

# Not compare the time (assuming usually the time boxes are left blank)

if {![empty_string_p $sale_begins(date)] && ![empty_string_p $sale_ends(date)]} {
    if {[db_0or1row select_one "select 1 from dual where to_date('$sale_begins(date)','YYYY-MM-DD HH24:MI:SS')  >to_date('$sale_ends(date)', 'YYYY-MM-DD HH24:MI:SS')"] ==1} {

	ad_return_complaint 1 "Please enter a start date before end date."
    }
}

# error checking done

# if offer_code_needed is yes_generate, I need to generate a offer_code
if { $offer_code_needed == "yes_generate" } {
    set offer_code [ec_generate_random_string 8]
}

# for the case where no offer code is required to get the sale price
if { ![info exists offer_code] } {
    set offer_code ""
}

set product_name [ec_product_name $product_id]

doc_body_append "[ad_admin_header "Confirm Sale Price for $product_name"]

<h2>Confirm Sale Price for $product_name</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index.tcl" "Products"] [list "one.tcl?[export_url_vars product_id]" $product_name] "Confirm Sale Price"]

<hr>
"

set currency [ad_parameter -package_id [ec_id] Currency ecommerce]

set sale_price_id [db_nextval ec_sale_price_id_sequence]

doc_body_append "<table>
<tr>
<td>Sale Price</td>
<td>[ec_pretty_price $sale_price $currency]</td>
</tr>
<tr>
<td>Name</td>
<td>$sale_name</td>
</tr>
<tr>
<td>Sale Begins</td>
<td>[util_AnsiDatetoPrettyDate [ec_date_text sale_begins]] [ec_time_text sale_begins]</td>
</tr>
<tr>
<td>Sale Ends</td>
<td>[util_AnsiDatetoPrettyDate [ec_date_text sale_ends]] [ec_time_text sale_ends]</td>
</tr>
<tr>
<td>Offer Code</td>
<td>[ec_decode $offer_code "" "None Needed" $offer_code]</td>
</tr>
</table>

<form method=post action=sale-price-add-2>
[export_form_vars sale_price_id product_id product_name sale_price sale_name offer_code]
<input type=hidden name=sale_begins value=\"[ec_datetime_text sale_begins]\">
<input type=hidden name=sale_ends value=\"[ec_datetime_text sale_ends]\">
<center>
<input type=submit value=\"Confirm\">
</center>

</form>
[ad_admin_footer]
"