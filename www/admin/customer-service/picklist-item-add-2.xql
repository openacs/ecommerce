<?xml version="1.0"?>
<queryset>

<fullquery name="get_picklist_item_id">      
      <querytext>
      select picklist_item_id from ec_picklist_items
where picklist_item_id=:picklist_item_id
      </querytext>
</fullquery>

 
<fullquery name="get_n_conflicts">      
      <querytext>
      select count(*)
from ec_picklist_items
where picklist_name=:picklist_name
and sort_key = :sort_key
      </querytext>
</fullquery>

 
</queryset>
