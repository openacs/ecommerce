<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<if @c_user_identification_id@ nil>
@customer_id_html;noquote@
</if>

<h3>One issue</h3><p>A customer may discuss several issues during the course of one interaction.  Please
enter the information about only one issue below:</p>

<form method="post" action="interaction-add-3">
 @export_form_vars1.html;noquote@
  <table cellspacing="1" cellpadding="2">
   @form_body_html;noquote@

<if @issue_id@ nil>
  <tr>
    <td bgcolor="#cccccc" valign="top" align="right"><p>Previous Issue ID:</p></td>
    <td bgcolor="#cccccc" valign="top"><input type="text" size="4" name="issue_id">
    <p>If this is a new issue, please leave this blank (a new Issue ID will be generated)</p></td>
    </tr>
    <tr>
    <td bgcolor="#cccccc" valign="top" align="right"><p>New Issue Type:</p></td>
    <td bgcolor="#cccccc" valign="top"><p>(leave blank if based on an existing issue) @issue_type_widget_html;noquote@</p></td>
    </tr>
    <tr>
    <td bgcolor="#99ccff" valign="top" align="right"><p>Order ID:</p></td>
    <td bgcolor="#99ccff" valign="top"><input type="text" size="7" name="order_id">
    <p>Fill this in if this inquiry is about a specific order.</p>
    </td>
    </tr>

</if><else>

<tr>
    <td bgcolor="#99ccff" valign="top" align="right"><p>Issue ID:</p></td>
    <td bgcolor="#99ccff" valign="top"><p>@issue_id@@export_form_vars_issue_id_html;noquote@</p></td>
    </tr>
    <tr>
    <td bgcolor="#99ccff" valign="top" align="right"><p>Issue Type</p></td>
    <td bgcolor="#99ccff" valign="top"><p>@issue_type_list_html;noquote@</p></td>
    </tr>
    <tr>
    <td bgcolor="#99ccff" valign="top" align="right"><p>Order ID:</p></td>
    <td bgcolor="#99ccff" valign="top"><p>@order_id_html;noquote@</p></td>
    </tr>
</else>

<tr>
<td bgcolor="#99ccff" valign="top" align="right"><p>Issue details:<br>(action_details)</p></td>
<td bgcolor="#99ccff" valign="top"><textarea wrap name="action_details" rows="6" cols="45"></textarea></td>
</tr>
<tr>
<td bgcolor="#99ccff" valign="top" align="right"><p>Resources used:</p></td>
<td bgcolor="#99ccff" valign="top"><p>Information used to respond to inquiry @info_used_widget_html;noquote@</p></td>
</tr>
<tr>
<td bgcolor="#99ccff" valign="top" align="right" rowspan="2"><p>Requires follow-up?</p></td>
<td bgcolor="#99ccff" valign="top"><p><input type=radio name=close_issue_p value="f" checked>yes <b>requires follow-up</b><br>
  &nbsp; &nbsp; Please&nbsp;elaborate:</p><textarea wrap name="follow_up_required" rows="2" cols="45"></textarea>
</td>
</tr>
<tr>

<td bgcolor="#99ccff" valign="top"><input type="radio" name="close_issue_p" value="t"><p>no (resolved)</p></td>
</tr>
</table>

<center><p>Customer</p>
<input type="submit" name="submit" value="Interaction complete">
<input type="submit" name="submit" value="Add another issue as part of this interaction">
</center>
</form>
