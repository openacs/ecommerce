<?xml version="1.0"?>
<queryset>

<fullquery name="get_picklist_items">      
      <querytext>
      
  select picklist_item
    from ec_picklist_items
   where picklist_name='info_used'
order by sort_key

      </querytext>
</fullquery>

 
</queryset>
