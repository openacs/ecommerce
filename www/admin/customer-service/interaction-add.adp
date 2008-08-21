<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<p>@early_message;noquote@</p>

<form method=post action=interaction-add-2>
@export_form_vars_html;noquote@

<table>
@table_rows_html;noquote@
<tr><td>Date &amp; Time:</td><td>@date_time_widget_html;noquote@</td></tr>
<tr><td>Inquired via:</td><td>@interaction_widget_html;noquote@</td></tr>
<tr><td>Who initiated this inquiry?</td><td><select name=interaction_originator>
  <option value="customer">customer</option><option value="rep">customer service rep</option></select></td></tr>
</table>

<if @user_identification_id@ nil>
 <p>Fill in any of the following information, which the system can use to try to identify the customer:</p>
  <table>
    <tr><td>First Name:</td><td><input type=text name=first_names size=15> Last Name: <input type=text name=last_name size=20></td></tr>
    <tr><td>Email Address:</td><td><input type=text name=email size=30></td></tr>
    <tr><td>Zip Code:</td><td><input type=text name=postal_code size=5 maxlength=5>
        If you fill this in, we'll determine which city/state they live in.</td></tr>
    <tr><td>Other Identifying Info:</td><td><input type=text name=other_id_info size=30></td></tr>
  </table>
</if>

<center>
  <input type=submit value="Continue">
</center>

</form>
