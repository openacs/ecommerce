<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<p>Please confirm that you want to end the sale price right now.</p>

<form method=post action=sale-price-expire-2>
@export_form_vars_html;noquote@

<center>
<input type=submit value="Confirm">
</center>

</form>
