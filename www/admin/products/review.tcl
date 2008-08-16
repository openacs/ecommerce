ad_page_contract {

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  review_id:integer,notnull
}

ad_require_permission [ad_conn package_id] admin

db_1row review_select "select * from ec_product_reviews where review_id=:review_id"
set review_date [clock format [clock scan $review_date] -format "%Y-%m-%d" -gmt true]

set product_name [ec_product_name $product_id]

set title "Professional Review of $product_name"
set context [list [list index Products] $title]

set summary_review "[ec_product_review_summary $author_name $publication $review_date]"
set display_p_html [util_PrettyBoolean $display_p]

set export_form_vars_html "[export_form_vars review_id product_id]"

set review_date_html "[ad_dateentrywidget review_date $review_date]"
set display_p_input_html "<input type=radio name=display_p value=\"t\" [ec_decode $display_p "t" "checked" ""]>Yes &nbsp; \
  <input type=radio name=display_p value=\"f\" [ec_decode $display_p "f" "checked" ""]>No"

# Set audit variables
# audit_name, audit_id, audit_id_column, return_url, audit_tables, main_tables
set audit_name "$product_name, Review:[ec_product_review_summary $author_name $publication $review_date]"
set audit_id $review_id
set audit_id_column "review_id"
set return_url "[ad_conn url]?[export_url_vars review_id]"
set audit_tables [list ec_product_reviews_audit]
set main_tables [list ec_product_reviews]
set audit_url_html "[ec_url_concat [ec_url] /admin]/audit?[export_url_vars audit_name audit_id audit_id_column return_url audit_tables main_tables]"
