<?xml version="1.0"?>
<queryset>

<fullquery name="get_subcategory_list">      
      <querytext>
      select subsubcategory_id from ec_subsubcategories where subcategory_id in (select subcategory_id from ec_subcategories where category_id=:category_id)
      </querytext>
</fullquery>

 
<fullquery name="get_subcategory_list_2">      
      <querytext>
      select subcategory_id from ec_subcategories where category_id=:category_id
      </querytext>
</fullquery>

 
<fullquery name="delete_ec_subcat_map">      
      <querytext>
      delete from ec_subsubcategory_product_map 
where subsubcategory_id in (select subsubcategory_id from ec_subsubcategories where subcategory_id in (select subcategory_id from ec_subcategories where category_id=:category_id))
      </querytext>
</fullquery>

 
<fullquery name="delete_ec_subcats">      
      <querytext>
      delete from ec_subsubcategories where subcategory_id in (select subcategory_id from ec_subcategories where category_id=:category_id)
      </querytext>
</fullquery>

 
<fullquery name="delete_ec_subcat_map_1">      
      <querytext>
      delete from ec_subcategory_product_map
where subcategory_id in (select subcategory_id from ec_subcategories where category_id=:category_id)
      </querytext>
</fullquery>

 
<fullquery name="delete_ec_subcats">      
      <querytext>
      delete from ec_subsubcategories where subcategory_id in (select subcategory_id from ec_subcategories where category_id=:category_id)
      </querytext>
</fullquery>

 
<fullquery name="delete_ec_cat_prodmap">      
      <querytext>
      delete from ec_category_product_map where category_id=:category_id
      </querytext>
</fullquery>

 
<fullquery name="delete_ec_cat_templates">      
      <querytext>
      delete from ec_category_template_map where category_id=:category_id
      </querytext>
</fullquery>

 
<fullquery name="delete_from_session_info">      
      <querytext>
      delete from ec_user_session_info where category_id=:category_id
      </querytext>
</fullquery>

 
<fullquery name="delete_ec_categories">      
      <querytext>
      delete from ec_categories where category_id=:category_id
      </querytext>
</fullquery>

 
</queryset>
