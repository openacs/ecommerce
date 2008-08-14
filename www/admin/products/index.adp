<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>
<ul>

<li>@n_products@ products 
(<a href="list">All</a> | 
<a href="by-category">By Category</a> |
<a href="add">Add</a>)

<p>

<li><a href="recommendations">Recommendations</a>
<li><a href="../cat/">Categorization</a>
<li><a href="custom-fields">Custom Fields</a>
<li><a href="upload-utilities">Bulk upload products</a>

<p>

<form method=post action=search>
<li>Search by Name: <input type=text name=product_name size=20>
<input type=submit value="Search">
</form>

<p>

<form method=post action=search>
<li>Search by SKU: <input type=text name=sku size=3>
<input type=submit value="Search">
</form>

<p>

<li><a href="@audit_html;noquote@">Audit all Products</a>
</ul>
