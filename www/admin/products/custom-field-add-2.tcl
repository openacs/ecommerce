#  www/[ec_url_concat [ec_url] /admin]/products/custom-field-add-2.tcl
ad_page_contract {
  Add a custom product field.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id custom-field-add-2.tcl,v 3.2.2.2 2000/07/22 07:57:37 ron Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
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
    append exception_text "<li>You forgot to enter a unique identifier."
} elseif { [regexp {[^a-z]} $field_identifier] } {
    incr exception_count
    append exception_text "<li>The unique identifier can only contain lowercase letters; no other characters are allowed."
} elseif { [string length $field_identifier] > 30 } {
    incr exception_count
    append exception_text "<li>The unique identifier is too long.  It can be at most 30 characters.  The current length is [string length $field_identifier] characters."
} else {
    
    if { [db_string dupliciate_field_identifier_select "select count(*) from ec_custom_product_fields where field_identifier=:field_identifier"] > 0 } {
	incr exception_count
	append exception_text "<li>The identifier $field_identifier has already been used.  Please choose another."
    } elseif { [db_string ec_products_column_conflict_select "select count(*) from user_tab_columns where column_name=upper(:field_identifier) and table_name='EC_PRODUCTS'"] } {
	incr exception_count
	append exception_text "<li>The identifier $field_identifer is already being used by the system in a different table.  Please choose another identifier to avoid ambiguity."
    }
}

if { [empty_string_p $field_name] } {
    incr exception_count
    append exception_text "<li>You forgot to enter a field name."
}

if { [empty_string_p $column_type] } {
    incr exception_count
    append exception_text "<li>You forgot to enter the kind of information."
}

if { $exception_count > 0 } {
    ad_return_complaint $exception_count $exception_text
    return
}

doc_body_append "[ad_admin_header "Confirm Custom Field"]

<h2>Confirm Custom Field</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index.tcl" "Products"] [list "custom-fields.tcl" "Custom Fields"] "Confirm New Custom Field"]

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
</table>

<p>

Please note that you can never remove a custom field, although you can deactivate it.  Furthermore, the Unique
Identifier cannot be changed and, in most cases, neither can Kind of Information.

<p>

<form method=post action=custom-field-add-3>
[export_form_vars field_identifier field_name default_value column_type]
<center>
<input type=submit value=\"Confirm\">
</center>
</form>

[ad_admin_footer]
"