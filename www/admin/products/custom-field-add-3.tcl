ad_page_contract {

    Add a custom product field.

    @author Eve Andersson (eveander@arsdigita.com)
    @creation-date Summer 1999
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse <bart.teeuwisse@7-sisters.com>
    @revision-date April 2002

} {
    field_identifier:sql_identifier
    field_name
    default_value
    column_type
}

ad_require_permission [ad_conn package_id] admin

# We need them to be logged in

set user_id [ad_get_user_id]
set peeraddr [ns_conn peeraddr]

# If the column type is boolean, we want to add a (named) check
# constraint at the end

if { $column_type == "char(1)" } {
    set end_of_alter ",\nconstraint ${field_identifier}_constraint check ($field_identifier in ('t', 'f'))"
} else {
    set end_of_alter ""
}

if { [db_string doubleclick_select "
    select count(*) 
    from ec_custom_product_fields 
    where field_identifier=:field_identifier"] > 0 } {

    # Then they probably just hit submit twice, so send them to
    # custom-fields.tcl

    ad_returnredirect "custom-fields"
    ad_script_abort
}

if { [catch { db_dml custom_field_insert "
    insert into ec_custom_product_fields
    (field_identifier, field_name, default_value, column_type, last_modified, last_modifying_user, modified_ip_address)
    values
    (:field_identifier, :field_name, :default_value, :column_type, sysdate, :user_id, :peeraddr)"} errmsg]} {
    ad_return_error "Unable to Add Field" "
	<p>Sorry, we were unable to add the field you requested.</p>
	<p>Here's the error message: <blockquote><pre>$errmsg</pre></blockquote></p>"
    ad_script_abort
}

# Have to alter ec_custom_product_field_values, the corresponding
# audit table, and the corresponding trigger

if {[catch { db_dml alter_ec_custom_field_values_table "
    alter table ec_custom_product_field_values 
    add ($field_identifier $column_type $end_of_alter)"} errmsg]} {

    # This means we were unable to add the column to
    # ec_custom_product_field_values, so undo the insert into
    # ec_custom_product_fields

    db_dml custom_field_delete "
	delete from ec_custom_product_fields 
	where field_identifier = :field_identifier"
    ad_return_error "Unable to Add Field" "
	<p>Sorry, we were unable to add the field you requested.</p>
	<p>The error occurred when adding the column $field_identifier to ec_custom_product_field_values, 
	  so we've deleted the row containing $field_identifier from ec_custom_product_fields as well (for consistency).</p>
	<p>Here's the error message: <blockquote><pre>$errmsg</pre></blockquote><p>"
    ad_script_abort
}

if {[catch {db_dml alter_ec_custom_field_values_audit_table "
    alter table ec_custom_p_field_values_audit 
    add ($field_identifier $column_type)"} errmsg]} {

    # This means we were unable to add the column to
    # ec_custom_p_field_values_audit, so undo the insert into
    # ec_custom_product_fields and the alteration to
    # ec_custom_product_field_values

    db_dml custom_field_delete "
	delete from ec_custom_product_fields
	where field_identifier = :field_identifier"
    db_dml custom_field_drop "
	alter table ec_custom_product_field_values 
	drop column $field_identifier"
    ad_return_error "Unable to Add Field" "
	<p>Sorry, we were unable to add the field you requested.</p>
	<p>The error occurred when adding the column $field_identifier to ec_custom_p_field_values_audit, 
	  so we've dropped that column from ec_custom_product_field_values and we've deleted the row containing $field_identifier 
	  from ec_custom_product_fields as well (for consistency).</p>
	<p>Here's the error message: <blockquote><pre>$errmsg</pre></blockquote></p>"
    ad_script_abort
}

# Determine what the new trigger should be

set database_type [db_type]
switch -exact $database_type {

    "oracle" {
	set new_trigger "
	    create or replace trigger ec_custom_p_f_values_audit_tr
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

	append new_trigger "[join $trigger_column_list ", "]) values (:old.[join $trigger_column_list ", :old."])"
	append new_trigger ";
            end;"

	# (2000-08-20 Seb) I don't know how to escape bind variables
	# (':old' in text of PL/SQL code will force Oracle driver to
	# look for Tcl var named 'old', and that's Not What We Want.
	# For the time being, I will resort to plainb ns_db call:

	db_with_handle db {
	    ns_db dml $db $new_trigger
	}
    }
    
    "postgresql" {
	set new_trigger_function "
	    create function ec_custom_p_f_values_audit_tr ()
	    returns opaque as '
	    begin
	       insert into ec_custom_p_field_values_audit ("

	db_with_handle db {
	    set trigger_column_list [list]
	    for {set i 0} {$i < [ns_column count $db ec_custom_product_field_values]} {incr i} {
		lappend trigger_column_list [ns_column name $db ec_custom_product_field_values $i]
	    }
	}

	append new_trigger_function "[join $trigger_column_list ", "]) values (old.[join $trigger_column_list ", old."]);"
	append new_trigger_function "
		return new;
            end;' language 'plpgsql'"

	db_transaction {
	    db_dml drop_trigger_function "drop function ec_custom_p_f_values_audit_tr ()"

	    # There is no XQL definition for create_trigger_function
	    # as the DML has been constructed on the fly.

	    db_dml create_trigger_function $new_trigger_function
	    db_dml drop_trigger "drop trigger ec_custom_p_f_values_audit_tr on ec_custom_product_field_values"
	    db_dml create_trigger "
		create trigger ec_custom_p_f_values_audit_tr
		before update or delete on ec_custom_product_field_values
		for each row execute procedure ec_custom_p_f_values_audit_tr ();"
	}
    }

    default {

	# Unknown database. 
    }
}
ad_returnredirect "custom-fields"
