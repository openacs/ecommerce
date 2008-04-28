<master>
<property name="title">@page_title@</property>
<property name="context_bar">@context_bar;noquote@</property>

<property name="show_toolbar_p">t</property>

<h2>@page_title@</h2>

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

<li><a href="[ec_url_concat [ec_url] /admin]/audit-tables?[export_url_vars table_names_and_id_column]">Audit all Products</a>
</ul>
