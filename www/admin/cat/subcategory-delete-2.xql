<?xml version="1.0"?>
<queryset>

<fullquery name="get_subsublist">      
      <querytext>
      select subsubcategory_id from ec_subsubcategories where subcategory_id=:subcategory_id
      </querytext>
</fullquery>

 
<fullquery name="delete_from_subsubmap">      
      <querytext>
      delete from ec_subsubcategory_product_map 
    where subsubcategory_id in (select subsubcategory_id from ec_subsubcategories where subcategory_id=:subcategory_id)
      </querytext>
</fullquery>

 
<fullquery name="delete_from_ecsubsub">      
      <querytext>
      delete from ec_subsubcategories where subcategory_id=:subcategory_id
      </querytext>
</fullquery>

 
<fullquery name="delete_from_ec_sub_map">      
      <querytext>
      delete from ec_subcategory_product_map where subcategory_id=:subcategory_id
      </querytext>
</fullquery>

 
<fullquery name="delete_from_ec_subcats">      
      <querytext>
      delete from ec_subcategories where subcategory_id=:subcategory_id
      </querytext>
</fullquery>

 
</queryset>
