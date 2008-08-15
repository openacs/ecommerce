#  www/[ec_url_concat [ec_url] /admin]/products/link-delete.tcl
ad_page_contract {

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  product_a:integer,notnull
  product_b:integer,notnull
  product_id:integer,notnull
}

ad_require_permission [ad_conn package_id] admin

set product_name [ec_product_name $product_id]

set title "Confirm Link To Delete"
set context [list [list index Products] $title]

set export_products_html [export_form_vars product_id product_a product_b]
