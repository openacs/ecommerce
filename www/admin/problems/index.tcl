#  www/[ec_url_concat [ec_url] /admin]/problems/index.tcl

ad_page_contract {
  This page dislpays the problems in the problem log, if display_all is
  not set then only unresolved problems are displayed.

  @author Jesse Koontz (jkoontz@arsdigita.com)
  @creation-date July 21, 1999
  @cvs-id index.tcl,v 3.2.2.3 2000/08/18 20:23:44 stevenp Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  display_all:optional
}

ad_require_permission [ad_conn package_id] admin

doc_body_append "[ad_admin_header "Potental Problems"]

<h2>Potential Problems</h2>

[ad_admin_context_bar [list "[ec_url_concat [ec_url] /admin]/" Ecommerce([ec_system_name])] "Potential Problems"]

<hr>
"

set problem_count [db_string unused_all "select count(*) from ec_problems_log"]
set unresolved_problem_count [db_string unused_null "select count(*) from ec_problems_log where resolved_date is null"]

if { ![info exists display_all] } {
    set sql_clause "and resolved_date is null"
    doc_body_append "
    <b>Unresolved Problems</b> <font size=-1>($unresolved_problem_count)</font> | <a href=\"index?display_all=true\">All Problems</a> <font size=-1>($problem_count)</font>
    <p>
    "
} else {
    set sql_clause ""
    doc_body_append "
    <a href=\"index\">Unresolved Problems</a> <font size=-1>($unresolved_problem_count)</font> | <b>All Problems</b> <font size=-1>($problem_count)</font>
    <p>
    "
}

doc_body_append "
<ul>
"

db_foreach problems_select "
 select 
      l.*, 
      u.first_names || ' ' || u.last_name as user_name
 from ec_problems_log l, 
      cc_users u
 where l.resolved_by = u.user_id(+)
      $sql_clause
 order by problem_date asc" {
    doc_body_append "
    <p>
    <li>[util_AnsiDatetoPrettyDate $problem_date] ("

    if { ![empty_string_p $order_id] } {
	doc_body_append "order #<a href=\"[ec_url_concat [ec_url] /admin]/orders/one?[export_url_vars order_id]\">$order_id</a> | "
    }

    if { [empty_string_p $resolved_date] } {
	doc_body_append "<a href=\"resolve?[export_url_vars problem_id]\">mark resolved</a>"
    } else {
	doc_body_append "resolved by [ec_admin_present_user $resolved_by $user_name] on [util_AnsiDatetoPrettyDate $resolved_date]"
    }

    doc_body_append ")
    <p>
    $problem_details
    <p>
    "
}

doc_body_append "
</ul>

[ad_admin_footer]
"


