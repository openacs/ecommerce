#  www/[ec_url_concat [ec_url] /admin]/products/link-add-2.tcl
ad_page_contract {
  Link a product.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  product_id:integer,notnull
  link_product_id:integer,notnull
}

ad_require_permission [ad_conn package_id] admin

set product_name [ec_product_name $product_id]
set link_product_name [ec_product_name $link_product_id]

set title "Create New Link, Cont."
set context [list [list index Products] $title]

set export_product_and_link_ids_html [export_url_vars product_id link_product_id]
