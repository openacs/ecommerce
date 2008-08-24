<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<form method=post action=issues>
@export_form_vars_html;noquote@

 <table border=0 cellspacing=0 cellpadding=0 width=100%>
  <tr bgcolor=#ececec>
   <td align=center><b>Issue Type</b></td>
   <td align=center><b>Status</b></td>
   <td align=center><b>Open Date</b></td>
  </tr>
  <tr>
   <td align=center><select name=view_issue_type>@issue_select_html;noquote@</select><input type=submit value="Change"></td>
   <td align=center>@linked_status_list_html;noquote@</td>
   <td align=center>@linked_open_date_list_html;noquote@</td>
  </tr>
 </table>

</form>

<if @row_counter@ gt 0>
 <table>@issues_list_html;noquote@</table>
</if><else>
 <center><p>None found.</p></center>
</else>
