<?xml version="1.0"?>
<queryset>

<fullquery name="get_item_match_no">      
      <querytext>
      select count(*) from ec_subsubcategories where subsubcategory_id=:subsubcategory_id and sort_key=:sort_key
      </querytext>
</fullquery>

 
<fullquery name="get_next_item_match">      
      <querytext>
      select count(*) from ec_subsubcategories where subsubcategory_id=:next_subsubcategory_id and sort_key=:next_sort_key
      </querytext>
</fullquery>

 
<fullquery name="update_ec_subsubcat">      
      <querytext>
      update ec_subsubcategories set sort_key=:next_sort_key where subsubcategory_id=:subsubcategory_id
      </querytext>
</fullquery>

 
<fullquery name="update_ec_subsubcat_2">      
      <querytext>
      update ec_subsubcategories set sort_key=:sort_key where subsubcategory_id=:next_subsubcategory_id
      </querytext>
</fullquery>

 
</queryset>
