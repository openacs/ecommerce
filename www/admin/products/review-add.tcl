#  www/[ec_url_concat [ec_url] /admin]/products/review-add.tcl
ad_page_contract {
  Review confirmation page.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  product_id:integer,notnull
  publication
  display_p
  review:html
  author_name
  review_date:array,date
}

ad_require_permission [ad_conn package_id] admin

set product_name [ec_product_name $product_id]

set title "Confirm Review of $product_name"
set context [list [list index Products] $title]

set review_id [db_nextval ec_product_review_id_sequence]
set review_summary_html [ec_product_review_summary $author_name $publication [ec_date_text review_date]]
set export_form_review_html [export_form_vars product_id publication display_p review review_id author_name]
set display_p_html [util_PrettyBoolean $display_p]
set review_date_html [ec_date_text review_date]
