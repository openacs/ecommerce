<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<form method=post action=interactions>
@export_form_vars_html

<table border=0 cellspacing=0 cellpadding=0 width=100%>
 <tr bgcolor=ececec>
  <td align=center><b>Rep</b></td>
  <td align=center><b>Originator</b></td>
  <td align=center><b>Type</b></td>
  <td align=center><b>Date</b></td>
 </tr>
 <tr>
  <td align=center><select name=view_rep><option value="all">All</option>@rep_info_by_rep_html;noquote@</select><input type=submit value="Change">
</td>
  <td align=center>@linked_interaction_originator_html;noquote@</td>
  <td align=center>@linked_interaction_type_html;noquote@</td>
  <td align=center>@linked_interaction_date_html;noquote@</td>
 </tr>
</table>

</form>

<if @row_counter eq 0>
    <center><p>None found.</p></center>
</if><else>
    @customer_interaction_detail_html;noquote@
</else>
