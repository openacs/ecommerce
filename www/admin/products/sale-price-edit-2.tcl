#  www/[ec_url_concat [ec_url] /admin]/products/sale-price-edit-2.tcl
ad_page_contract {
  Update a sale price.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id sale-price-edit-2.tcl,v 3.1.6.3 2000/08/18 20:23:47 stevenp Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  sale_price_id:integer,notnull
  product_id:integer,notnull
  sale_price:notnull
  sale_name:optional
  sale_begins:array,date
  sale_ends:array,date
  offer_code_needed
  offer_code:optional
}

ad_require_permission [ad_conn package_id] admin

if {![regexp {^[0-9|.]+$} $sale_price ]} {
    ad_return_complaint 1 "The price you entered is not a valid number."
    return
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

set exception_count 0
set exception_text ""

if { $offer_code_needed == "yes_supplied" && (![info exists offer_code] || [empty_string_p $offer_code]) } {
    incr exception_count
    append exception_text "<li>You forgot to specify an offer code.\n"
}

if { $exception_count > 0 } {
    ad_return_complaint $exception_count $exception_text
    return
}

# error checking done

set product_name [ec_product_name $product_id]

# if offer_code_needed is yes_generate, I need to generate a offer_code
if { $offer_code_needed == "yes_generate" } {
    set offer_code [ec_generate_random_string 8]
}

# for the case where no offer code is required to get the sale price
if { ![info exists offer_code] } {
    set offer_code ""
}

doc_body_append "[ad_admin_header "Confirm Sale Price for $product_name"]

<h2>Confirm Sale Price for $product_name</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index.tcl" "Products"] [list "one.tcl?[export_url_vars product_id]" $product_name] "Confirm Sale Price"]

<hr>
"

set currency [ad_parameter -package_id [ec_id] Currency ecommerce]



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

<form method=post action=sale-price-edit-3>
[export_form_vars sale_price_id product_id product_name sale_price sale_name offer_code]
<input type=hidden name=sale_begins value=\"[ec_datetime_text sale_begins]\">
<input type=hidden name=sale_ends value=\"[ec_datetime_text sale_ends]\">
<center>
<input type=submit value=\"Confirm\">
</center>

</form>
[ad_admin_footer]
"