<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<form method=post action=interactions>
 @export_form_vars_html;noquote@
 <table border="0" cellspacing="0" cellpadding="1" width="100%">
  <tr bgcolor="#ececec">
   <td align="center"><b>Rep</b></td>
   <td align="center"><b>Originator</b></td>
   <td align="center"><b>Type</b></td>
   <td align="center"><b>Date</b></td>
  </tr>
  <tr>
   <td align="center"><select name="view_rep">@rep_info_by_rep_html;noquote@</select><input type=submit value="Change"></td>
   <td align="center">@interaction_originator_html;noquote@</td>
   <td align="center">@interaction_type_list_html;noquote@</td>
   <td align="center">@interaction_date_list_html;noquote@</td>
  </tr>
 </table>
</form>

<if @row_counter@ gt 0>
 <table>
  @customer_interaction_detail_html;noquote@
 </table>
</if><else>
  <p>None found.</p>
</else>
