#  www/[ec_url_concat [ec_url] /admin]/problems/resolve.tcl

ad_page_contract {
  This page confirms that a problems in the problem log is resolved

  @author Jesse Koontz (jkoontz@arsdigita.com)
  @creation-date July 21, 1999
  @cvs-id resolve.tcl,v 3.1.6.5 2000/09/22 01:34:58 kevin Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  problem_id:integer,notnull
}

ad_require_permission [ad_conn package_id] admin

db_1row problem_select "select problem_details, problem_date from ec_problems_log where problem_id = :problem_id"

db_release_unused_handles

doc_return  200 text/html "[ad_admin_header "Confirm the Problem is Resolved"]

<h2>Confirm that Problem is Resolved</h2>

[ad_admin_context_bar [list "[ec_url_concat [ec_url] /admin]/" Ecommerce([ec_system_name])] [list "index.tcl" "Potential Problems"] "Confirm Resolve Problem"]

<hr>

<form method=post action=\"resolve-2\">
[export_form_vars problem_id]
<blockquote>

<p>
<blockquote>
[util_AnsiDatetoPrettyDate $problem_date]
<p>
$problem_details
</blockquote>
<center>
<input type=submit value=\"Yes, it is resolved\">
</center>

</blockquote>
</form>

[ad_admin_footer]
"
