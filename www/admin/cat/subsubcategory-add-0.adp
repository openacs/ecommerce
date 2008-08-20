<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<ul>
<li>
 <form method=post action=subsubcategory-add>
  @export_form_vars_html;noquote@
  Name: <input type=text name=subsubcategory_name size=30>
  <input type=submit value="Add">
 </form>
</li>
</ul>
