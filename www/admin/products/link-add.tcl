#  www/[ec_url_concat [ec_url] /admin]/products/link-add.tcl
ad_page_contract {

  @author
  @creation-date Summer 1999
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  product_id:integer,notnull
  link_product_name:optional
  link_product_sku:integer,notnull,optional
}

ad_require_permission [ad_conn package_id] admin

set product_name [ec_product_name $product_id]

set title "Create New Products Link"
set context [list [list index Products] $title]

if { [info exists link_product_sku] } {
    set additional_query_part "sku=:link_product_sku"
} else {
    set additional_query_part "upper(product_name) like '%' || upper(:link_product_name) || '%'"
}

set doc_body ""
set no_rows 0

db_foreach product_search_select "select product_id as link_product_id, product_name as link_product_name from ec_products where $additional_query_part" {
    append doc_body "<li><a href=\"link-add-2?[export_url_vars product_id link_product_id]\">$link_product_name</a>\n"
} if_no_rows {
    set no_rows 1
}
