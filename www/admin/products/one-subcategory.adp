<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<if @product_counter@ eq 0>
o<p>There are no products in this subcategory.</p>
</if><else>
<ul>
@get_product_infos_html;noquote@
</ul>
</else>
