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
where field_identifier=:field_identifier
"

doc_body_append "[ad_admin_header "$field_name"]

<h2>$field_name</h2>

[ad_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index" "Products"] [list "custom-fields" "Custom Fields"] "One Custom Field"]

<hr>

<table noborder>
<tr>
<td>Unique Identifier:</td>
<td>$field_identifier</td>
</tr>
<tr>
<td>Field Name:</td>
<td>$field_name</td>
</tr>
<tr>
<td>Default Value:</td>
<td>$default_value</td>
</tr>
<tr>
<td>Kind of Information:</td>
<td>[ec_pretty_column_type $column_type]</td>
</tr>
<tr>
<td>Active:</td>
<td>[util_PrettyBoolean $active_p]</td>
</tr>
</table>

<p>

<h3>Actions:</h3>

<p>

<ul>
<li><a href=\"custom-field-edit?field_identifier=$field_identifier\">Edit</a>
"

if { $active_p == "t" } {
    doc_body_append "<li><a href=\"custom-field-status-change?field_identifier=$field_identifier&active_p=f\">Make Inactive</a>"
} else {
    doc_body_append "<li><a href=\"custom-field-status-change?field_identifier=$field_identifier&active_p=t\">Reactivate</a>"
}

# Set audit variables
# audit_name, audit_id, audit_id_column, return_url, audit_tables, main_tables
set audit_name "$field_name"
set audit_id $field_identifier
set audit_id_column "field_identifier"
set return_url "custom-field?[export_url_vars field_identifier]"
set audit_tables [list ec_custom_product_fields_audit]
set main_tables [list ec_custom_product_fields]

doc_body_append "<li><a href=\"[ec_url_concat [ec_url] /admin]/audit?[export_url_vars audit_name audit_id audit_id_column return_url audit_tables main_tables]\">Audit Trail</a>
</ul>

[ad_admin_footer]
"
