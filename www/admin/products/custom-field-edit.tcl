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

doc_body_append "
    [ad_admin_header "Edit $field_name"]

    <h2>Edit $field_name</h2>

    [ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index" "Products"] [list "custom-fields" "Custom Fields"] "Edit Custom Field"]

    <hr>

    <form method=post action=custom-field-edit-2>
    [export_form_vars old_column_type field_identifier]
    
    <table noborder>
      <tr>
        <td>Unique Identifier:</td>
        <td><code>$field_identifier</code></td>
        <td>This can't be changed.</td>
      </tr>
      <tr>
        <td>Field Name:</td>
        <td><input type=text name=field_name value=\"[ad_quotehtml $field_name]\" size=25 maxlength=100></td>
        <td></td>
      </tr>
      <tr>
        <td>Default Value:</td>
        <td><input type=text name=default_value value=\"[ad_quotehtml $default_value]\" size=15 maxlength=100></td>
        <td></td>
      </tr>
      <tr>
        <td>Kind of Information:</td>
        <td>[ec_column_type_widget $column_type]</td>
        <td>We might not be able to change this, depending on what it
          is, what you're trying to change it to, and what values are
          already in the database for this field (you can always try it
          &amp; find out).</td>
      </tr>
    </table>
    
    <center>
      <input type=submit value=\"Submit Changes\">
    </center>
    </form>
    [ad_admin_footer]"
