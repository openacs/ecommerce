#  www/[ec_url_concat [ec_url] /admin]/products/recommendation-add-2.tcl
ad_page_contract {
  Recommend a product.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  product_id:integer,notnull
}

ad_require_permission [ad_conn package_id] admin

set product_name [ec_product_name $product_id]

set title "Add a Product Recommendation"
set context [list [list index Products] $title]

set export_form_vars_html [export_form_vars product_id]
set recommended_for_html [ec_user_class_widget]
set display_in_html [ec_category_widget "f" "" "t"]
