<?xml version="1.0"?>
<queryset>

<fullquery name="get_item_match_count">      
      <querytext>
      select count(*) from ec_categories where category_id=:category_id and sort_key=:sort_key
      </querytext>
</fullquery>

 
<fullquery name="get_next_item_match_count">      
      <querytext>
      select count(*) from ec_categories where category_id=:next_category_id and sort_key=:next_sort_key
      </querytext>
</fullquery>

 
<fullquery name="update_swap_cat_1">      
      <querytext>
      update ec_categories set sort_key=:next_sort_key where category_id=:category_id
      </querytext>
</fullquery>

 
<fullquery name="update_swap_cat_2">      
      <querytext>
      update ec_categories set sort_key=:sort_key where category_id=:next_category_id
      </querytext>
</fullquery>

 
</queryset>
