<master src="/www/site-master">
  <property name="title">@title;noquote@</property>
  <if @header_stuff@ not nil><property name="header_stuff">@header_stuff;noquote@</property></if>
  <if @context@ not nil><property name="context">@context;noquote@</property></if>
  <if @context_bar@ not nil><property name="context_bar">@context_bar;noquote@</property></if>
  <if @focus@ not nil><property name="focus">@focus;noquote@</property></if>
  <if @doc_type@ not nil><property name="doc_type">@doc_type;noquote@</property></if>

<if @is_not_in_ecommerce_p@ true>
   <include src="/packages/ecommerce/www/toolbar" />
</if>
<else>
   <if @show_toolbar_p@ not nil>
   <include src="/packages/ecommerce/www/toolbar" combocategory_id=@combocategory_id@ category_id=@category_id@ subcategory_id=@subcategory_id@ search_text=@search_text@ />
    </if>
</else>
    
<div id="page-body">
  <if @title@ not nil>
    <h1 class="page-title">@title;noquote@</h1>
  </if>

  <slave>
  <div style="clear: both;"></div>
</div>

