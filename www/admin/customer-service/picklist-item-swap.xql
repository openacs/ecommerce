<?xml version="1.0"?>
<queryset>

<fullquery name="get_item_match">      
      <querytext>
      select count(*) from ec_picklist_items where picklist_item_id=:picklist_item_id and sort_key=:sort_key
      </querytext>
</fullquery>

 
<fullquery name="get_next_item_match">      
      <querytext>
      select count(*) from ec_picklist_items where picklist_item_id=:next_picklist_item_id and sort_key=:next_sort_key
      </querytext>
</fullquery>

 
<fullquery name="update_current_item">      
      <querytext>
      update ec_picklist_items set sort_key=:next_sort_key where picklist_item_id=:picklist_item_id
      </querytext>
</fullquery>

 
<fullquery name="update_next_item">      
      <querytext>
      update ec_picklist_items set sort_key=:sort_key where picklist_item_id=:next_picklist_item_id
      </querytext>
</fullquery>

 
</queryset>
