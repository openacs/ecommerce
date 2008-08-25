<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<h3>What we know about this user</h3>

<table>
<tr>
<td align=right><b>First Name</td>
<td>@first_names@</td>
</tr>
<tr>
<td align=right><b>Last Name</td>
<td>@last_name@</td>
</tr>
<tr>
<td align=right><b>Email</td>
<td>@email@</td>
</tr>
<tr>
<td align=right><b>Postal Code</td>
<td>@postal_code@
<if @location@ not nil>
 (@location@)
</if>
</td>
</tr>
<tr>
<td align=right><b>Other Identifying Info</td>
<td>@other_id_info@</td>
</tr>
<tr>
<td align=right><b>Record Created</b></td>
<td>@record_created_html;noquote@</td>
</tr>
</table>

<h3>Customer Service Issues</h3>
<h3>Edit User Info</h3>

<form method=post action=user-identification-edit>
@export_form_vars_html;noquote@
<table>
<tr>
<td>First Name:</td>
<td><input type=text name=first_names size=15 value="@first_names@"> Last Name: <input type=text name=last_name size=20 value="@last_name@"></td>
</tr>
<tr>
<td>Email Address:</td>
<td><input type=text name=email size=30 value="@email@"></td>
</tr>
<tr>
<td>Zip Code:</td>
<td><input type=text name=postal_code size=5 maxlength=5 value="@postal_code@"></td>
</tr>
<tr>
<td>Other Identifying Info:</td>
<td><input type=text name=other_id_info size=30 value="@other_id_info@"></td>
</tr>
</table>

<center>
<input type=submit value="Update">
</center>
</form>

<h3>Try to match this user up with a registered user</h3>

<form method=post action=user-identification-match>
 @export_form_vars_html;noquote@
 <ul>
  @comments_about_user_html;noquote@
 </ul>
<if @d_user_id@ not nil>
 <center>
  <input type=submit value="Confirm they are the same person">
 </center>
</if><else>
 <p>No matches found.</p>
</else>
</form>
