<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<p>
Please confirm that you want this to become the default template that products will be displayed with
if no template has been specifically assigned to them.
</p>
<form method=post action=make-default-2>
@export_form_vars_html;noquote@
<center>
  <input type=submit value="Confirm">
</center>
</form>
