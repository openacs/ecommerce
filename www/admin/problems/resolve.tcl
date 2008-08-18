#  www/[ec_url_concat [ec_url] /admin]/problems/resolve.tcl

ad_page_contract {
  This page confirms that a problems in the problem log is resolved

  @author Jesse Koontz (jkoontz@arsdigita.com)
  @creation-date July 21, 1999
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  problem_id:integer,notnull
}

ad_require_permission [ad_conn package_id] admin

db_1row problem_select "select problem_details, problem_date from ec_problems_log where problem_id = :problem_id"

db_release_unused_handles

set title "Confirm the Problem is Resolved"
set context [list [list index "Potential Problems"] $title]

set export_form_vars_html [export_form_vars problem_id]
set problem_date_html [util_AnsiDatetoPrettyDate $problem_date]

