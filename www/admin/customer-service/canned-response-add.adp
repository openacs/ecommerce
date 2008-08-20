<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<form action=canned-response-add-2 method=POST>
 <table noborder>
  <tr><th>Description</th><td><input type=text size=60 name=one_line></tr>
  <tr><th>Text</th><td><textarea name=response_text rows=25 cols=60 wrap=soft></textarea></tr>
  <tr><td align=center colspan=2><input type=submit value=Submit></tr>
 </table>
</form>
