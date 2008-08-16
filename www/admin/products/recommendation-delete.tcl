#  www/[ec_url_concat [ec_url] /admin]/products/recommendation-delete.tcl
ad_page_contract {
  Confirmation page, takes no action.

  @author philg@mit.edu
  @creation-date July 18, 1999
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  recommendation_id:integer,notnull
}

ad_require_permission [ad_conn package_id] admin

set title "Really Delete Product Recommendation?"
set context [list [list index Products] $title]

db_1row recommendation_select "select r.*, p.product_name
from ec_product_recommendations r, ec_products p
where recommendation_id=:recommendation_id
and r.product_id=p.product_id"

if { ![empty_string_p $user_class_id] } {
    set user_class_description "[db_string user_class_name_select "select user_class_name from ec_user_classes where user_class_id=:user_class_id"]"
} else {
    set user_class_description "all users"
}

set export_form_vars_html [export_form_vars recommendation_id]

