<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<p>Please confirm that you wish to delete this item.</p>

<form method=post action=picklist-item-delete-2>
  @export_form_vars_html;noquote@
  <input type=submit value="Confirm">
</form>
