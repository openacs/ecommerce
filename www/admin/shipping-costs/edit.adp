<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<p>Please confirm that you want shipping to be charged as follows:</p>
@shipping_costs_html;noquote@

<form method=post action=edit-2>
  @export_form_vars_html;noquote@

<center>
  <input type=submit value="Confirm">
</center>
</form>
