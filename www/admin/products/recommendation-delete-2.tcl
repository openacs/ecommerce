#  www/[ec_url_concat [ec_url] /admin]/products/recommendation-delete-2.tcl
ad_page_contract {
  Actually deletes the row.

  @author philg@mit.edu
  @creation-date July 18, 1999
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  recommendation_id:integer,notnull
}

ad_require_permission [ad_conn package_id] admin

db_dml recommendation_delete "delete from ec_product_recommendations where recommendation_id=:recommendation_id"

ec_audit_delete_row [list $recommendation_id] [list recommendation_id] ec_product_recommend_audit

ad_returnredirect "recommendations.tcl"
