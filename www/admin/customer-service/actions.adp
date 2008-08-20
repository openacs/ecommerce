<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<form method=post action=actions>
 @export_form_vars_html;noquote@
 <table border=0 cellspacing=0 cellpadding=0 width=100%>
  <tr bgcolor=#ececec>
   <td align=center><b>Info Used</b></td>
   <td align=center><b>Rep</b></td>
   <td align=center><b>Interaction Date</b></td>
  </tr>
  <tr>
   <td align=center><select name=view_info_used>@info_used_list_html;noquote@</select><input type=submit value="Change"></td>
   <td align=center><select name=view_rep><option value="all">All</option>@customer_service_data_html;noquote@</select><input type=submit value="Change"></td>
   <td align=center>@interaction_date_list_html;noquote@</td>
  </tr>
 </table>
</form>

<if @row_counter@ gt 0>
 <table>
  @interaction_info_maybe_rep_html;noquote@
 </table>
</if><else>
  <p>None found.</p>
</else>
