#  www/[ec_url_concat [ec_url] /admin]/products/recommendation-text-edit.tcl
ad_page_contract {
  Entry form to let user edit the HTML text of a recommendation.

  @author philg@mit.edu on 
  @creation-date July 18, 1999
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  recommendation_id:integer,notnull
}

ad_require_permission [ad_conn package_id] admin

set title "Edit Product Recommendation Text"
set context [list [list index Products] $title]

db_1row recommendation_select "select r.*, p.product_name
from ec_product_recommendations r, ec_products p
where recommendation_id=$recommendation_id
and r.product_id=p.product_id"

set export_form_vars_html [export_form_vars recommendation_id]

