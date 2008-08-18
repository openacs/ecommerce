ad_page_contract {

    Add items, Cont.

    @author Eve Andersson (eveander@arsdigita.com)
    @creation-date Summer 1999
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @revision-date April 2002

} {
    order_id:integer,notnull
    product_id:integer,notnull
    color_choice
    size_choice
    style_choice
}

ad_require_permission [ad_conn package_id] admin

set title "Add Items, continued"
set context [list [list index "Orders / Shipments / Refunds"] $title]

set item_id [db_nextval ec_item_id_sequence]
set user_id [db_string user_id_select "
    select user_id 
    from ec_orders 
    where order_id=:order_id"]
set lowest_price_and_price_name [ec_lowest_price_and_price_name_for_an_item $product_id $user_id ""]

set price_name [lindex $lowest_price_and_price_name 1]
set price_charged [format "%0.2f" [lindex $lowest_price_and_price_name 0]]
set currency [parameter::get -package_id [ec_id] -parameter Currency -default "USD"]
set export_form_vars_html [export_form_vars order_id product_id color_choice size_choice style_choice item_id]
