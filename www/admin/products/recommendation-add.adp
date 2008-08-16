<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<p>Please choose the product you wish to recommend.</p>

<if @product_count@ gt 0>
 <ul>
  @product_search_select_html;noquote@
 </ul>
</if><else>
  <p>No matching products were found.</p>
</else>
