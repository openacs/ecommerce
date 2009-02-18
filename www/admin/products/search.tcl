#  www/[ec_url_concat [ec_url] /admin]/products/search.tcl
ad_page_contract {
  Search for a product based on name or sku.

  @author Eve Andersson (eveander@arsdigita.com)
  @author Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
  @creation-date Summer 1999
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  sku:notnull,optional
  product_name:optional
}

ad_require_permission [ad_conn package_id] admin

if { [info exists sku] } {
    set sku_search $sku
    set additional_query_part "sku=:sku_search"
    set description "Products with SKU #$sku:"
} else {
    set product_name_search $product_name
    set additional_query_part "upper(product_name) like '%' || upper(:product_name_search) || '%'"
    set description "Products whose name includes \"$product_name_search\":"
}



set title "Product Search"
set context [list [list index Products] $title]

set product_counter 0
set product_search_select_html ""
db_foreach product_search_select "select product_id, sku, product_name from ec_products where $additional_query_part order by product_name" {
    incr product_counter
    if { $sku eq ""} {
        set sku $product_id
    }
    append product_search_select_html "<li><a href=\"one?[export_url_vars product_id]\" target=\"_blank\">$product_name</a> ($sku)</li>\n"
} if_no_rows {
    # do nothing for product_name
    if { [info exists sku_search] } {
        #    set additional_query_part "sku=:sku"
        set sku_search $sku
        set additional_query_part "upper(sku) like '%' || upper(:sku_search) || '%'"
        set description "No product with sku $sku_search found.  Products whose sku includes \"${sku_search}\":"
        #    set sku [string tolower $sku]
        set product_counter 0
        set product_search_select_html ""
        db_foreach product_search_select "select product_id, sku, product_name from ec_products where $additional_query_part order by product_name" {
            incr product_counter
            if { $sku eq ""} {
                set sku $product_id
            }
            append product_search_select_html "<li><a href=\"one?[export_url_vars product_id]\" target=\"_blank\">${product_name}</a> ($sku)</li>\n"
        }
    } 
}
