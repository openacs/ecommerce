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
  @cvs-id audit-one-id.tcl,v 3.0.12.5 2000/09/22 01:34:46 kevin Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  id:sql_identifier,notnull
  id_column:notnull,sql_identifier
  audit_table_name:notnull,sql_identifier
  main_table_name:notnull,sql_identifier
}

ad_require_permission [ad_conn package_id] admin

set table_names_and_id_column [list $main_table_name $audit_table_name $id_column]

set page_content "
[ad_admin_header "[ec_system_name] Audit of $id_column $id"]

<h2>[ec_system_name] Audit Trail</h2>

[ad_admin_context_bar [list index Ecommerce([ec_system_name])] [list "audit-tables?[export_url_vars table_names_and_id_column]" "Audit $main_table_name"] "[ec_system_name] Audit Trail"]
<hr>

<h3>$main_table_name</h3>
<blockquote>

[ec_audit_trail $id $audit_table_name $main_table_name $id_column]

</blockquote>

[ad_admin_footer]
"



doc_return  200 text/html $page_content
