<?xml version="1.0"?>
<queryset>

<fullquery name="get_count_items">      
      <querytext>
      select count(*)
from ec_picklist_items
where picklist_name=:picklist_name
and sort_key = (:prev_sort_key + :next_sort_key)/2
      </querytext>
</fullquery>

 
</queryset>
