#  /www/[ec_url_concat [ec_url] /admin]/audit.tcl
ad_page_contract {

  Displays the audit info for one id in the id_column of a table and its 
  audit history.

  @author Jesse
  @creation-date 7/17
  @cvs-id audit.tcl,v 3.0.12.4 2000/08/20 10:59:30 seb Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  audit_name:html
  audit_id:sql_identifier,notnull
  audit_id_column:sql_identifier,notnull
  return_url:optional
  audit_tables:notnull
  main_tables:notnull
}

ad_require_permission [ad_conn package_id] admin

doc_body_append "
[ad_admin_header "[ec_system_name] Audit Trail"]
<h2>$audit_name</h2>

[ad_admin_context_bar [list index Ecommerce([ec_system_name])] "Audit Trail"]
<hr>
"

set counter 0

foreach main_table $main_tables {
    doc_body_append "<h3>$main_table</h3>
    <blockquote>

    [ec_audit_trail $audit_id [lindex $audit_tables $counter] $main_table $audit_id_column]

    </blockquote>
    "
    incr counter
}

doc_body_append "[ad_admin_footer]"
