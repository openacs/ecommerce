<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<ul>
<li>
 <form method=post action=subsubcategory-edit>
 @export_form_vars_html;noquote@
 Change subsubcategory name to:
 <input type=text name=subsubcategory_name size=30 value="@subsubcategory_name@">
 <input type=submit value="Change">
 </form>
</li>
<li><a href="../products/one-subsubcategory?@export_form_vars_css_html;noquote@">View all products in this subsubcategory</a>.</li>
<li><a href="subsubcategory-delete?@export_form_vars_css_html;noquote@">Delete this subsubcategory</a>.</li>
<li><a href="@audit_url_html;noquote">Audit Trail</a></li>
</ul>
