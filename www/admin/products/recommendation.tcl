#  www/[ec_url_concat [ec_url] /admin]/products/recommendation.tcl
ad_page_contract {
  Display one recommendation.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  recommendation_id:integer,notnull
}

ad_require_permission [ad_conn package_id] admin

db_1row recommendation_select "select r.*, p.product_name
from  ec_recommendations_cats_view r, ec_products p
where recommendation_id=:recommendation_id
and r.product_id=p.product_id"

set title "Product Recommendation"
set context [list [list index Products] $title]


if { ![empty_string_p $user_class_id] } {
    set user_class_name_select_html "[db_string user_class_name_select "select user_class_name from ec_user_classes where user_class_id=:user_class_id"]"
} else {
    set user_class_name_select_html "All Users"
}

if { [empty_string_p $the_category_id] && [empty_string_p $the_subcategory_id] && [empty_string_p $the_subsubcategory_id] } {
    set category_level_html "Top Level"
} else {
    set category_level_html "[ec_category_subcategory_and_subsubcategory_display $the_category_id $the_subcategory_id $the_subsubcategory_id]"
}

set export_url_rec_html [export_url_vars recommendation_id]

# Set audit variables
# audit_name, audit_id, audit_id_column, return_url, audit_tables, main_tables
set audit_name Recommendation
set audit_id $recommendation_id
set audit_id_column "recommendation_id"
set return_url "[ad_conn url]?[export_url_vars product_id]"
set audit_tables [list ec_product_recommend_audit]
set main_tables [list ec_product_recommendations]

set audit_url_html "[ec_url_concat [ec_url] /admin]/audit?[export_url_vars audit_name audit_id audit_id_column return_url audit_tables main_tables]"

