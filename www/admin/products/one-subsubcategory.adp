<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<if @has_rows@ false>
<p>There are no products in this subsubcategory.</p>
</if><else>
<ul>
@select_subsubcate_html;noquote@
</ul>
</else>
