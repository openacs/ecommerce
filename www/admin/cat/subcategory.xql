<?xml version="1.0"?>
<queryset>

<fullquery name="get_subcategory_infos">      
      <querytext>
      select subsubcategory_id, sort_key, subsubcategory_name from ec_subsubcategories where subcategory_id=:subcategory_id order by sort_key
      </querytext>
</fullquery>

 
</queryset>
