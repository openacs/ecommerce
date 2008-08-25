<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>
<p>
Are you sure you want to <b>delete @product_name@?</b>
</p>
<p>The system will not let you delete a product if anyone has already ordered it
(you might want to mark the product "discontinued" instead).
</p>
<p>
<form method=post action=delete-2>
@export_vars_html;noquote@
<center>
<input type=submit value="Yes">
</center>
</form>
