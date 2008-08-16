#  www/[ec_url_concat [ec_url] /admin]/products/recommendation-add.tcl
ad_page_contract {
  Search for a product to recommend.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  product_name_query
}

ad_require_permission [ad_conn package_id] admin

set title "Add a Product Recommendation"
set context [list [list index Products] $title]

set product_count 0
set product_search_select_html ""
db_foreach product_search_select "select product_name, product_id
    from ec_products
    where upper(product_name) like '%' || upper(:product_name_query) || '%'" {
    append product_search_select_html "<li>$product_name \[<a href=\"one?[export_url_vars product_id]\">view</a> | <a href=\"recommendation-add-2?[export_url_vars product_name product_id]\">recommend</a>\] ($product_id)</li>\n"
    incr product_count
}

