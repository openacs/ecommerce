<?xml version="1.0"?>
<queryset>

<fullquery name="items_update">      
      <querytext>
      
  update ec_items
  set item_state='void',
  voided_by=:customer_service_rep
  where order_id=:order_id
  
      </querytext>
</fullquery>

 
</queryset>
