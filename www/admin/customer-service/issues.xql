<?xml version="1.0"?>
<queryset>

<fullquery name="get_issue_type_list">      
      <querytext>
      select picklist_item from ec_picklist_items where picklist_name='issue_type' order by sort_key
      </querytext>
</fullquery>

 
</queryset>
