<?xml version="1.0"?>
<queryset>

<fullquery name="get_list_name">      
      <querytext>
      select category_name from ec_categories where category_id=:category_id
      </querytext>
</fullquery>

 
<fullquery name="get_mailing_list_name">      
      <querytext>
      select category_name from ec_categories where category_id=:category_id
      </querytext>
</fullquery>

 
<fullquery name="get_subcat_listname">      
      <querytext>
      select subcategory_name from ec_subcategories where subcategory_id=:subcategory_id
      </querytext>
</fullquery>

 
<fullquery name="get_category_name">      
      <querytext>
      select category_name from ec_categories where category_id=:category_id
      </querytext>
</fullquery>

 
<fullquery name="get_subcategory_name">      
      <querytext>
      select subcategory_name from ec_subcategories where subcategory_id=:subcategory_id
      </querytext>
</fullquery>

 
<fullquery name="get_subsubcategory_name">      
      <querytext>
      select subsubcategory_name from ec_subsubcategories where subsubcategory_id=:subsubcategory_id
      </querytext>
</fullquery>

 
</queryset>
