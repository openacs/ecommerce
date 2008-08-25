<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<form method=post action="audit-table">
 @export_form_vars_html;noquote@
 <table>
  <tr>
   <td>From:</td>
   <td>@start_date_html;noquote@</td>
  </tr>
  <tr>
   <td>To:</td>
   <td>@end_date_html;noquote@</td>
  </tr>
  <tr>
   <td colspan="2" align="center"><input type=submit value="Alter Date Range"></td>
  </tr>
 </table>
</form>

<h3>@main_table_name@</h3>

@main_table_html;noquote@


