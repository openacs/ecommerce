ad_page_contract {

    @author Eve Andersson (eveander@arsdigita.com)
    @creation-date Summer 1999
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @revision-date April 2002

} {
    field_identifier:sql_identifier,notnull
    field_name:notnull
    default_value
    column_type:notnull
    old_column_type:notnull
}

ad_require_permission [ad_conn package_id] admin

# We need them to be logged in
set user_id [ad_get_user_id]

# I'm not going to let them change from a non-boolean column type to a
# boolean one because it's too complicated adding the constraint
# (because first you change the column type and then you try to add
# the constraint, but if you fail when you add the constraint, you've
# still changed the column type (there's no rollback when you're
# altering tables), and in theory I could then change the column type
# back to the original one if the constraint addition fails, but what
# if that fails, so I'm just not going to allow it).

if { $old_column_type != "char(1)" && $column_type == "char(1)"} {
    ad_return_complaint 1 "<li>The Kind of Information cannot be changed from non-boolean to boolean.</li>"
    ad_script_abort
}

if {[catch {
    if { $column_type != $old_column_type } {

	# If the old column_type is a boolean, then let's drop the old
	# constraint

	if { $old_column_type == "char(1)" } {
	    db_dml alter_table_drop "
		alter table ec_custom_product_field_values 
		drop constraint ${field_identifier}_constraint"
	}

	db_dml alter_table_modify "
	    alter table ec_custom_product_field_values
	    modify ($field_identifier $column_type)"
	db_dml alter_table_modify_audit "
	    alter table ec_custom_p_field_values_audit
	    modify ($field_identifier $column_type)"
    }
} errmsg]} {
    ad_return_complaint 1 "<li>The modification of Kind of Information failed.  Here is the error message that the database gave us:<blockquote>$errmsg</blockquote></li>"
    ad_script_abort
}

set peeraddr [ns_conn peeraddr]
db_dml custom_fields_update "
    update ec_custom_product_fields set field_name = :field_name, default_value = :default_value, column_type = :column_type, 
    	last_modified = sysdate, last_modifying_user = :user_id, modified_ip_address = :peeraddr
    where field_identifier = :field_identifier"

ad_returnredirect "custom-fields"
