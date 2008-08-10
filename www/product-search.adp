<master>
  <property name="title">Product search @category_name@</property>
  <property name="current_location">Product Search</property>
  <property name="search_text">@search_text@</property>
  <property name="category_id">@category_id@</property>
  <property name="subcategory_id">@subcategory_id@</property>
  <property name="combocategory_id">@combocategory_id@</property>

  <include src="/packages/ecommerce/lib/toolbar"/>
  <include src="/packages/ecommerce/lib/searchbar" combocategory_id=@combocategory_id@ category_id=@category_id@ subcategory_id=@subcategory_id@ search_text=@search_text@ />
  
    @search_results;noquote@
  



