# /www/[ec_url_concat [ec_url] /admin]/audit-one-id.tcl
ad_page_contract {

  Displays the audit info for one id in the id_column of a table and
  its audit history.

  @param id
  @param id_column
  @param audit_table_name
  @param main_table_name

  @author Jesse
  @creation-date Summer 1999
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  id:sql_identifier,notnull
  id_column:notnull,sql_identifier
  audit_table_name:notnull,sql_identifier
  main_table_name:notnull,sql_identifier
}

ad_require_permission [ad_conn package_id] admin

set table_names_and_id_column [list $main_table_name $audit_table_name $id_column]

set title "Audit of $id_column $id"
set context [list $title]

set audit_trail_html "[ec_audit_trail $id $audit_table_name $main_table_name $id_column]"
