#  www/[ec_url_concat [ec_url] /admin]/audit-table.tcl
ad_page_contract {

  Returns the audit trails of a table and its audit table for entry that
  exists between the start date and end date.

  @param table_names_and_id_column
  @param start_date
  @param start_time
  @param end_date
  @param end_time

  @author Jesse (jkoontz@mit.edu)
  @creation-date 7/18
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {

  table_names_and_id_column:notnull
  start_date:array,date
  start_time:array,time
  end_date:array,date
  end_time:array,time

} -validate {

  start_timestamp_valid {
      if { [exists_and_not_null start_time(time)]  &&
	  ![exists_and_not_null start_date(date)]  ||
	   [exists_and_not_null end_time(time)]  &&
	  ![exists_and_not_null end_date(date)] } {

	ad_complain "You cannot leave date field empty if you're entered
	             something in the time field.  Reverse is, however,
		     acceptable."
      }
  }
}

ad_require_permission [ad_conn package_id] admin

set main_table_name  [lindex $table_names_and_id_column 0]
set audit_table_name [lindex $table_names_and_id_column 1]
set id_column [lindex $table_names_and_id_column 2]

if { ![empty_string_p $start_date(date)]  &&
      [empty_string_p $start_time(time)] } {
    set start_time(time) "00:00:00"
}

if { ![empty_string_p $end_date(date)]  &&
      [empty_string_p $end_time(time)] } {
    set end_time(time) "00:00:00"
}
# Not compare the time (assuming usually the time boxes are left blank)

if {![empty_string_p $start_date(date)] && ![empty_string_p $end_date(date)]} {
    if {[db_0or1row select_one "
    select 1
      from dual
     where to_date('$start_date(date)','YYYY-MM-DD HH24:MI:SS')  > to_date('$end_date(date)', 'YYYY-MM-DD HH24:MI:SS')
    "] ==1} {

	ad_return_complaint 1 "Please enter a start date before end date."
    }
}

doc_body_append "
[ad_admin_header "[ec_system_name] Audit Table"]

<h2>[ec_system_name] Audit for $main_table_name</h2>

[ad_context_bar [list "index.tcl" Ecommerce([ec_system_name])] [list "audit-tables" "Audit Table"] "Audit $main_table_name"]

<hr>

<form method=post action=\"audit-table\">
[export_form_vars table_names_and_id_column]
<table>
<tr>
  <td>From:</td>
  <td>[ad_dateentrywidget start_date $start_date(date)]&nbsp;[ec_timeentrywidget start_time $start_time(time)]</td>
</tr>
<tr>
  <td>To:</td>
  <td>[ad_dateentrywidget end_date $end_date(date)]&nbsp;[ec_timeentrywidget end_time $end_time(time)]</td>
</tr>
<tr>
<td></td>
<td><input type=submit value=\"Alter Date Range\"></td>
</tr>
</table>
</form>

<h3>$main_table_name</h3>
"

if { ![empty_string_p $start_date(date)] } {
    append start_date(date) " $start_time(time)"
}

if { ![empty_string_p $end_date(date)] } {
    append end_date(date) " $end_time(time)"
}

doc_body_append "
    <blockquote>
      [ec_audit_trail_for_table $main_table_name $audit_table_name $id_column $start_date(date) $end_date(date) "audit-one-id" ""]
    </blockquote>

[ad_admin_footer]
"
