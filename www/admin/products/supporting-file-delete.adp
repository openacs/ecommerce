<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<p>Please confirm that you wish to delete this file.</p>
<p>@comments@</p>

<form method=post action=supporting-file-delete-2>
@export_form_vars_html;noquote@
<center>
<input type=submit value="Confirm">
</center>
</form>
