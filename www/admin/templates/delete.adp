<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<p>
Please confirm that you want to delete this template.  If any products are set to use this template, they will
now be displayed with the default template.
</p>
<form method=post action=delete-2>
  @export_form_vars_html;noquote@
<center>
  <input type=submit value="Confirm">
</center>
</form>
