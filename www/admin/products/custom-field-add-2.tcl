ad_page_contract {

    Add a custom product field.

    @author Eve Andersson (eveander@arsdigita.com)
    @creation-date Summer 1999
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @revision-date April 2002

} {
    field_identifier
    field_name
    default_value
    column_type
}

ad_require_permission [ad_conn package_id] admin

set field_identifier [string tolower $field_identifier]

set exception_count 0
set exception_text ""

if { [empty_string_p $field_identifier] } {
    incr exception_count
    append exception_text "<li>The form requires a unique identifier.</li>"
} elseif { [regexp {[^a-z]} $field_identifier] } {
    incr exception_count
    append exception_text "<li>The unique identifier can only contain lowercase letters; no other characters are allowed.</li>"
} elseif { [string length $field_identifier] > 30 } {
    incr exception_count
    append exception_text "<li>The unique identifier is too long.  It can be at most 30 characters.  The current length is [string length $field_identifier] characters.</li>"
} else {
    
    if { [db_string dupliciate_field_identifier_select "select count(*) from ec_custom_product_fields where field_identifier=:field_identifier"] > 0 } {
	incr exception_count
	append exception_text "<li>The identifier $field_identifier has already been used.  Please choose another.</li>"
    } elseif { [db_string ec_products_column_conflict_select "select count(*) from user_tab_columns where column_name=upper(:field_identifier) and table_name='EC_PRODUCTS'"] } {
	incr exception_count
	append exception_text "<li>The identifier $field_identifer is already being used by the system in a different table.  Please choose another identifier to avoid ambiguity.</li>"
    }
}

if { [empty_string_p $field_name] } {
    incr exception_count
    append exception_text "<li>Form requires a field name.</li>"
}

if { [empty_string_p $column_type] } {
    incr exception_count
    append exception_text "<li>Form requires identifying the field type (kind of information).</li>"
}

if { $exception_count > 0 } {
    ad_return_complaint $exception_count $exception_text
    return
}

set title "Confirm Custom Field"
set context [list [list index Products] $title]

set column_type_html [ec_pretty_column_type $column_type]

set export_form_vars_html [export_form_vars field_identifier field_name default_value column_type]
