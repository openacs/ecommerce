<?xml version="1.0"?>
<queryset>

<fullquery name="get_interation_originator_list">      
      <querytext>
      select unique interaction_originator from ec_customer_serv_interactions
      </querytext>
</fullquery>

 
<fullquery name="get_interaction_type_list">      
      <querytext>
      select picklist_item from ec_picklist_items where picklist_name='interaction_type' order by sort_key
      </querytext>
</fullquery>

 
</queryset>
