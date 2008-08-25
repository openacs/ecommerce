#  /www/[ec_url_concat [ec_url] /admin]/audit.tcl
ad_page_contract {

  Displays the audit info for one id in the id_column of a table and its 
  audit history.

  @author Jesse
  @creation-date 7/17
  @cvs-id $Id$
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

set title "[ec_system_name] Audit Trail"
set context [list $title]

set counter 0
set main_table_html ""
foreach main_table $main_tables {
    append main_table_html "<h3>$main_table</h3> [ec_audit_trail $audit_id [lindex $audit_tables $counter] $main_table $audit_id_column]"
    incr counter
}

