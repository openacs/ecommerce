<?xml version="1.0"?>
<queryset>

<fullquery name="delete_subsub_map">      
      <querytext>
      delete from ec_subsubcategory_product_map where subsubcategory_id=:subsubcategory_id
      </querytext>
</fullquery>

 
<fullquery name="delete_subsubcats">      
      <querytext>
      delete from ec_subsubcategories where subsubcategory_id = :subsubcategory_id
      </querytext>
</fullquery>

 
</queryset>
