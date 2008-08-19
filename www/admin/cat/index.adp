<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<h3>Current Categories</h3>

<if @category_counter@ gt 0>
 <table>
  @categories_loop_html;noquote@
 </table>
</if><else>
 <p>
  There are no categories yet.  <a href="category-add-0?prev_sort_key=1&next_sort_key=2">Add a category.</a>
</p>
</else>
