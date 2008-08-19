<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<form method=post action=edit-2>
  @export_form_vars_html;noquote@
  <p>Name: <input type=text name=template_name size=30 value="@template_name@"></p>
  <p>ADP template:<br>
    <textarea name=template rows=30 cols=60>@template@</textarea></p>
<center>
  <input type=submit value="Submit Changes">
</center>
</form>
