ad_page_contract {

    Add a sale price.

    @author Eve Andersson (eveander@arsdigita.com)
    @creation-date Summer 1999
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @revision-date April 2002

} {
    product_id:integer,notnull
    {price:optional ""}
    sale_price:notnull
    {sale_name:html "Sale Price"}
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

# TODO : imporve validation of sale_begins and sale_ends

if { [empty_string_p [ec_datetime_text sale_begins]] } {
    ad_return_complaint 1 "You forgot to enter the time that the sale begins."
    return
}

if { [empty_string_p [ec_datetime_text sale_ends]] } {
    ad_return_complaint 1 "You forgot to enter the time that the sale begins."
    return
}

# Not compare the time (assuming usually the time boxes are left
# blank)

if {![empty_string_p $sale_begins(date)] && ![empty_string_p $sale_ends(date)]} {
    if {[db_0or1row select_one "select 1 from dual where to_date('$sale_begins(date)','YYYY-MM-DD HH24:MI:SS')  >to_date('$sale_ends(date)', 'YYYY-MM-DD HH24:MI:SS')"] ==1} {

	ad_return_complaint 1 "Please enter a start date before end date."
    }
}

# Error checking done

# If offer_code_needed is yes_generate, I need to generate a
# offer_code

if { $offer_code_needed == "yes_generate" } {
    set offer_code [ec_generate_random_string 8]
}

# For the case where no offer code is required to get the sale price

if { ![info exists offer_code] } {
    set offer_code ""
}

set product_name [ec_product_name $product_id]

set title "Confirm Sale Price for $product_name"
set context [list [list index Products] $title]

set currency [parameter::get -package_id [ec_id] -parameter Currency -default "USD"]

set sale_price_id [db_nextval ec_sale_price_id_sequence]

set sale_price_html [ec_pretty_price $sale_price $currency]
set sale_begins_html "[util_AnsiDatetoPrettyDate [ec_date_text sale_begins]] [ec_time_text sale_begins]"
set sale_ends_html "[util_AnsiDatetoPrettyDate [ec_date_text sale_ends]] [ec_time_text sale_ends]"
set offer_code_html [ec_decode $offer_code "" "None Needed" $offer_code]
set export_form_vars_html [export_form_vars sale_price_id product_id product_name sale_price sale_name offer_code]

set form_sale_begins_html [ec_datetime_text sale_begins]
set form_sale_ends_html [ec_datetime_text sale_ends]
