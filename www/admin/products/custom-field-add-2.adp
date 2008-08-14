<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

    <table noborder>
      <tr>
        <td>Unique Identifier:</td>
        <td>@field_identifier@</td>
      </tr>
      <tr>
        <td>Field Name:</td>
        <td>@field_name@</td>
      </tr>
      <tr>
        <td>Default Value:</td>
        <td>@default_value@</td>
      </tr>
      <tr>
        <td>Kind of Information:</td>
        <td>@column_type_html;noquote@</td>
      </tr>
    </table>
    
    <p>Please note that you can never remove a custom field, although
      you can deactivate it.  Furthermore, the Unique Identifier cannot
      be changed and, in most cases, neither can Kind of Information.</p>
    
    <form method=post action=custom-field-add-3>
   @export_form_vars_html;noquote@
      <center>
        <input type=submit value="Confirm">
      </center>
    </form>
