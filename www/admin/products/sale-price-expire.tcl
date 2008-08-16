#  www/[ec_url_concat [ec_url] /admin]/products/sale-price-expire.tcl
ad_page_contract {
  Confirm sale expire.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  sale_price_id:integer,notnull
  product_id:integer,notnull
}

ad_require_permission [ad_conn package_id] admin

set product_name [ec_product_name $product_id]

set title "Expire Sale Price for $product_name"
set context [list [list index Products] $title]

set export_form_vars_html [export_form_vars product_id sale_price_id]
