<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<if @repeat_sku_warn@ true>
<p>Warning: More than one product has been assigned to the following skus.  Some bulk actions may not work as expected.</p>
<p> @repeat_skus;noquote@</p>
</if>

<ul>

<li>@n_products@ products 
(<a href="list">All</a> | 
<a href="by-category">By Category</a> |
<a href="add">Add</a>)
</li>
<li>

<li><a href="recommendations">Recommendations</a></li>
<li><a href="../cat/">Categorization</a></li>
<li><a href="custom-fields">Custom Fields</a></li>
<li><a href="upload-utilities">Bulk upload products</a></li>



<form method=post action=search>
<li>Search by Name: <input type=text name=product_name size=40>
<input type=submit value="Search"></li>
</form>
<br>


<form method=post action=search>
<li>Search by SKU: <input type=text name=sku size=40>
<input type=submit value="Search"></li>
</form>
<br>


<li><a href="@audit_html;noquote@">Audit all Products</a></li>
</ul>
