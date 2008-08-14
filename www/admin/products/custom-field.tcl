# /www/[ec_url_concat [ec_url] /admin]/products/custom-field.tcl
ad_page_contract {

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  field_identifier:sql_identifier
}

ad_require_permission [ad_conn package_id] admin

db_1row custom_field_select "
select field_name, default_value, column_type, active_p
from ec_custom_product_fields
where field_identifier=:field_identifier"

set title "Custom Field ${field_name}"
set context [list [list index Products] $title]

set column_type_html [ec_pretty_column_type $column_type]
set active_p_html [util_PrettyBoolean $active_p]

# Set audit variables
# audit_name, audit_id, audit_id_column, return_url, audit_tables, main_tables
set audit_name "$field_name"
set audit_id $field_identifier
set audit_id_column "field_identifier"
set return_url "custom-field?[export_url_vars field_identifier]"
set audit_tables [list ec_custom_product_fields_audit]
set main_tables [list ec_custom_product_fields]

set audit_url_html "[ec_url_concat [ec_url] /admin]/audit?[export_url_vars audit_name audit_id audit_id_column return_url audit_tables main_tables]"
