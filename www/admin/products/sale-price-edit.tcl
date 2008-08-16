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

set title "Edit Sale Price for $product_name"
set context [list [list index Products] $title]

set export_form_vars_html [export_form_vars product_id product_name sale_price_id]

db_1row sale_price_select "
    select sale_price, to_char(sale_begins,'YYYY-MM-DD HH24:MI:SS') as sale_begins, to_char(sale_ends,'YYYY-MM-DD HH24:MI:SS') as sale_ends, sale_name, offer_code 
    from ec_sale_prices
    where sale_price_id = :sale_price_id"

set sale_begins_html "[ad_dateentrywidget sale_begins [ec_date_with_time_stripped $sale_begins]] [ec_time_widget sale_begins [lindex [split $sale_begins " "] 1]]"
set sale_ends_html "[ad_dateentrywidget sale_ends [ec_date_with_time_stripped $sale_ends]] [ec_time_widget sale_ends [lindex [split $sale_ends " "] 1]]"

set offer_code_none_html [ec_decode $offer_code "" "checked" ""]
set offer_code_required_html [ec_decode $offer_code "" "" "checked"]
set offer_code_new_html [ec_decode $offer_code "" "" "new"]
set currency_html [parameter::get -package_id [ec_id] -parameter Currency -default "USD"]
