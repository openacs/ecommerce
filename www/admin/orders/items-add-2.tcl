ad_page_contract {

    @author Eve Andersson (eveander@arsdigita.com)
    @creation-date Summer 1999
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @revision-date April 2002

} {
    order_id:integer,notnull
    sku:optional
    product_name:optional
}

ad_require_permission [ad_conn package_id] admin

set title "Add Items, continued"
set context [list [list index "Orders / Shipments / Refunds"] $title]

if { [exists_and_not_null sku] } {
    set additional_query_part "sku=:sku"
} else {
    set additional_query_part "upper(product_name) like '%' || upper(:product_name) || '%'"
}

set product_counter 0
set products_select_html ""
db_foreach products_select "select product_id, product_name 
    from ec_products 
    where $additional_query_part" {
    incr product_counter
	append products_select_html "<li><p><a href=\"[ec_url_concat [ec_url] /admin]/products/one?[export_url_vars product_id]\">$product_name</a> [ec_add_to_cart_link $product_id "Add to Order" "Add to Order" "items-add-3" $order_id]</p></li>"
}
