<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<if @default_template_p;literal@ true>
  <p>This is the default template used for product display.</p>
</if>
<h3>The template: @template_name@</h3>
<pre>
@template@
</pre>
<br>
<h3>Actions:</h3>
<ul>
  <li><a href="edit?@export_url_vars_html@">Edit</a></li>
  <li><a href="add?based_on=@template_id@">Create new template based
  on this one</a></li>
 <if @default_template_p;literal@ false>
  <li><a href="make-default?@export_url_vars_html@">Make this template be the default template</a></li>
  <li><a href="delete?@export_url_vars_html@">Delete</a></li>
</if><else>
<li>Delete (Default template cannot be deleted. To delete this
template, make another template the default.)</li>
</else>
<li><a href="category-associate?@export_url_vars_html@">Associate this template with a product category</a></li>
<li><a href="@audit_url_html@">Audit Trail</a></li>
</ul>
