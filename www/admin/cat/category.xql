<?xml version="1.0"?>
<queryset>

<fullquery name="get_subcat_info_loop">      
      <querytext>
      select subcategory_id, sort_key, subcategory_name from ec_subcategories where category_id=:category_id order by sort_key
      </querytext>
</fullquery>

 
</queryset>
