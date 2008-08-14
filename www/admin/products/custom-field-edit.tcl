ad_page_contract {

    Edit a custom product field.

    @author Eve Andersson (eveander@arsdigita.com)
    @creation-date Summer 1999
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @revision-date May 2002

} {
    field_identifier:sql_identifier
}

ad_require_permission [ad_conn package_id] admin

db_1row custom_field_select "
    select field_name, default_value, column_type, active_p
    from ec_custom_product_fields
    where field_identifier=:field_identifier"

set old_column_type $column_type

set title "Edit $field_name"
set context [list [list index Products] $title]

set export_vars_html [export_form_vars old_column_type field_identifier]
set column_type_html [ec_column_type_widget $column_type]
