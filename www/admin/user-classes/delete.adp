<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<p>Are you sure you want to delete this user class?</p>
<p>Users who are currently in this class will be without a class.</p>

<form method=post action=delete-2>
@export_form_vars_html;noquote@
<center>
  <input type=submit value="Yes / Confirm">
</center>
</form>

