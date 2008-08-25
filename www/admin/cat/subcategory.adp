<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<ul>
<li>Change subcategory name to:
 <form method=post action=subcategory-edit>
  @export_form_vars_html;noquote@
  <input type=text name=subcategory_name size=30 value="@subcategory_name@">
  <input type=submit value="Change">
 </form>
</li>
<li><a href="../products/one-subcategory?@export_form_vars_cs_html;noquote@">View all products in this subcategory</a></li>
<li><a href="subcategory-delete?@export_form_vars_cs_html;noquote@">Delete this subcategory</a></li>
<li><a href="@audit_url_html">Audit Trail</a>
</ul>

<h3>Current Subsubcategories of @subcategory_name@</h3>
<if @subsubcategory_counter@ gt 0>
<table>
@subcategory_infos_html;noquote@
</table>
</if><else>
<p>There are no subsubcategories for this subcategory.  <a href="subsubcategory-add-0?@export_url_vars_2_html;noquote@&prev_sort_key=1&next_sort_key=2">Add a subsubcategory</a>.</p>
</else>
