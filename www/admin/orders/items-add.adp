<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<p>Search for a product to add:</p>
<form method=post action=items-add-2>
  @export_form_vars_html;noquote@
  <ul>
  <li>By Name: <input type=text name=product_name size=20> <input type=submit value="Search"></li>
  </ul>
</form>
<form method=post action=items-add-2>
  @export_form_vars_html;noquote@
  <ul>
  <li>By SKU: <input type=text name=sku size=3> <input type=submit value="Search"></li>
  </ul>
</form>

