<?xml version="1.0"?>
<queryset>

<fullquery name="get_mailing_list_name">      
      <querytext>
      select category_name from ec_categories where category_id=:category_id
      </querytext>
</fullquery>

 
<fullquery name="get_mailing_list_name">      
      <querytext>
      select category_name from ec_categories where category_id=:category_id
      </querytext>
</fullquery>

 
<fullquery name="get_subcat_ml_name">      
      <querytext>
      select subcategory_name from ec_subcategories where subcategory_id=:subcategory_id
      </querytext>
</fullquery>

 
<fullquery name="get_cat_ml_name">      
      <querytext>
      select category_name from ec_categories where category_id=:category_id
      </querytext>
</fullquery>

 
<fullquery name="get_ml_subcat_name">      
      <querytext>
      select subcategory_name from ec_subcategories where subcategory_id=:subcategory_id
      </querytext>
</fullquery>

 
<fullquery name="get_subsub_ml_name">      
      <querytext>
      select subsubcategory_name from ec_subsubcategories where subsubcategory_id=:subsubcategory_id
      </querytext>
</fullquery>

 
</queryset>
