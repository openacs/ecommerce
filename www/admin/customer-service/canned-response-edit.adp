<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<form action=canned-response-edit-2 method=POST>
 @export_form_vars_html;noquote@
 <table noborder>
  <tr><th>Description</th><td><input type=text size=60 name=one_line value="@one_line@"></tr>
  <tr><th>Text</th><td><textarea name=response_text rows=5 cols=70 wrap=soft>@response_text@</textarea></tr>
  <tr><td align=center colspan=2><input type=submit value=Submit></tr>
 </table>
</form>
