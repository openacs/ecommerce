#  www/[ec_url_concat [ec_url] /admin]/products/custom-field-add-3.tcl
ad_page_contract {
  Add a custom product field.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id custom-field-add-3.tcl,v 3.2.2.3 2000/08/20 11:20:43 seb Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  field_identifier:sql_identifier
  field_name
  default_value
  column_type
}

ad_require_permission [ad_conn package_id] admin

# we need them to be logged in
set user_id [ad_get_user_id]

# if the column type is boolean, we want to add a (named) check constraint at the end
if { $column_type == "char(1)" } {
    set end_of_alter ",\nconstraint ${field_identifier}_constraint check ($field_identifier in ('t', 'f'))"
} else {
    set end_of_alter ""
}



if { [db_string doubleclick_select "select count(*) from ec_custom_product_fields where field_identifier=:field_identifier"] > 0 } {
    # then they probably just hit submit twice, so send them to custom-fields.tcl
    ad_returnredirect "custom-fields"
}

set peeraddr [ns_conn peeraddr]

set audit_fields "last_modified, last_modifying_user, modified_ip_address"
#set audit_info "sysdate, :user_id, :peeraddr"
set audit_info [db_map audit_info_sql]

set insert_statement "insert into ec_custom_product_fields
(field_identifier, field_name, default_value, column_type, $audit_fields)
values
(:field_identifier, :field_name, :default_value, :column_type, $audit_info)"

if [catch { db_dml custom_product_field_insert $insert_statement } errmsg] {
    ad_return_error "Unable to Add Field" "Sorry, we were unable to add the field you requested.  Here's the error message: <blockquote><pre>$errmsg</pre></blockquote>"
    return
}

# have to alter ec_custom_product_field_values, the corresponding audit
# table, and the corresponding trigger

#set alter_statement "alter table ec_custom_product_field_values add (
#    $field_identifier $column_type$end_of_alter
##)"
set alter_statement [db_map alter_statement_sql]

if [catch { db_dml alter_table $alter_statement } errmsg] {
    # this means we were unable to add the column to ec_custom_product_field_values, so undo the insert into ec_custom_product_fields
    db_dml custom_field_delete "delete from ec_custom_product_fields where field_identifier=:field_identifier"
    ad_return_error "Unable to Add Field" "Sorry, we were unable to add the field you requested.  The error occurred when adding the column $field_identifier to ec_custom_product_field_values, so we've deleted the row containing $field_identifier from ec_custom_product_fields as well (for consistency).  Here's the error message: <blockquote><pre>$errmsg</pre></blockquote>"
    return
}

# 1999-08-10: took out $end_of_alter because the constraints don't
# belong in the audit table

#set alter_statement_2 "alter table ec_custom_p_field_values_audit add (
#    $field_identifier $column_type
#)"
set alter_statement_2 [db_map alter_statement_2_sql]

if [catch {db_dml alter_table_2 $alter_statement_2} errmsg] {
    # this means we were unable to add the column to ec_custom_p_field_values_audit, so undo the insert into ec_custom_product_fields and the alteration to ec_custom_product_field_values
    db_dml custom_field_delete "delete from ec_custom_product_fields where field_identifier=:field_identifier"
    db_dml custom_field_drop "alter table ec_custom_product_field_values drop column $field_identifier"
    ad_return_error "Unable to Add Field" "Sorry, we were unable to add the field you requested.  The error occurred when adding the column $field_identifier to ec_custom_p_field_values_audit, so we've dropped that column from ec_custom_product_field_values and we've deleted the row containing $field_identifier from ec_custom_product_fields as well (for consistency).  Here's the error message: <blockquote><pre>$errmsg</pre></blockquote>"
    return
}

# determine what the new trigger should be
set new_trigger_beginning "create or replace trigger ec_custom_p_f_values_audit_tr
before update or delete on ec_custom_product_field_values
for each row
begin
	insert into ec_custom_p_field_values_audit ("

db_with_handle db {
  set trigger_column_list [list]
  for {set i 0} {$i < [ns_column count $db ec_custom_product_field_values]} {incr i} {
    lappend trigger_column_list [ns_column name $db ec_custom_product_field_values $i]
  }
}

set new_trigger_columns [join $trigger_column_list ", "]

set new_trigger_middle ") values ("

set new_trigger_values ":old.[join $trigger_column_list ", :old."]"

set new_trigger_end ");
end;
"

set new_trigger "$new_trigger_beginning
$new_trigger_columns
$new_trigger_middle
$new_trigger_values
$new_trigger_end"

#  (2000-08-20 Seb) I don't know how to escape bind variables (':old' in
#  text of PL/SQL code will force Oracle driver to look for Tcl var named
#  'old', and that's Not What We Want.  For the time being, I will resort
#  to plainb ns_db call:

db_with_handle db {
  ns_db dml $db $new_trigger
}

ad_returnredirect "custom-fields"
