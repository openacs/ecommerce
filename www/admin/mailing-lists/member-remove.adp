<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<p>Are you sure you want to remove this user from this mailing list?</p>

<form method=post action=member-remove-2>
  @export_form_vars_html;noquote@
<center>
  <input type=submit value="Confirm">
</center>
</form>
