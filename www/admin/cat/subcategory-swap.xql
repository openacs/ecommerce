<?xml version="1.0"?>
<queryset>

<fullquery name="get_item_match">      
      <querytext>
      select count(*) from ec_subcategories where subcategory_id=:subcategory_id and sort_key=:sort_key
      </querytext>
</fullquery>

 
<fullquery name="get_next_item_match">      
      <querytext>
      select count(*) from ec_subcategories where subcategory_id=:next_subcategory_id and sort_key=:next_sort_key
      </querytext>
</fullquery>

 
<fullquery name="update_swap_subcat">      
      <querytext>
      update ec_subcategories set sort_key=:next_sort_key where subcategory_id=:subcategory_id
      </querytext>
</fullquery>

 
<fullquery name="update_swap_subcat_2">      
      <querytext>
      update ec_subcategories set sort_key=:sort_key where subcategory_id=:next_subcategory_id
      </querytext>
</fullquery>

 
</queryset>
