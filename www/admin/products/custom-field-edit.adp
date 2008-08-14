<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

    <form method=post action=custom-field-edit-2>
    @export_vars_html;noquote@
    
    <table noborder>
      <tr>
        <td>Unique Identifier:</td>
        <td><code>@field_identifier@</code></td>
        <td>This can't be changed.</td>
      </tr>
      <tr>
        <td>Field Name:</td>
        <td><input type=text name=field_name value="@field_name@" size=25 maxlength=100></td>
        <td></td>
      </tr>
      <tr>
        <td>Default Value:</td>
        <td><input type=text name=default_value value="@default_value@" size=15 maxlength=100></td>
        <td></td>
      </tr>
      <tr>
        <td>Kind of Information:</td>
        <td>@column_type_html;noquote@</td>
        <td>We might not be able to change this, depending on what it
          is, what you're trying to change it to, and what values are
          already in the database for this field (you can always try it
          &amp; find out).</td>
      </tr>
    </table>
    
    <center>
      <input type=submit value="Submit Changes">
    </center>
    </form>
