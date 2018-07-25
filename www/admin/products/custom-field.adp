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
<tr>
<td>Active:</td>
<td>@active_p_html;noquote@</td>
</tr>
</table>

<h3>Actions:</h3>

<ul>
<li><a href="custom-field-edit?field_identifier=@field_identifier@">Edit</a>

<if @active_p;literal@ true>
<li><a href="custom-field-status-change?field_identifier=@field_identifier@&active_p=f">Make Inactive</a>
</if><else>
<li><a href="custom-field-status-change?field_identifier=@field_identifier@&active_p=t">Reactivate</a>
</else>

<li><a href="@audit_url_html;noquote@">Audit Trail</a>
</ul>

