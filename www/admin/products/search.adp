<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<p>@description@</p>

<if @product_counter@ eq 0>
<p>No matching products were found.</p>
</if></else>

<ul>
@product_search_select_html;noquote@
</ul>
</else>
