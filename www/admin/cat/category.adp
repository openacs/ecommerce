<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<ul>

<li>Change category name to:
<form method=post action=category-edit>
@export_form_vars_html;noquote@
<input type=text name=category_name size=30 value="@category_name@">
<input type=submit value="Change">
</form>
</li>

  <li><a href="../products/list?@export_url_vars_cat_id@">View all products in this category</a></li>
  <li><a href="category-delete?@export_url_vars_cat_id_name@">Delete this category</a></li>
  <li><a href="@audit_url_html;noquote@">Audit Trail</a></li>
</ul>


<h3>Current Subcategories of @category_name@</h3>
<if @subcategory_counter@ gt 0>
<table>
 @subcat_info_loop_html;noquote@
</table>
</if><else>
<p>No subcategories found.</p>
<p>@subcat_add_html;noquote@</p>
</else>
