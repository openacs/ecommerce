<?xml version="1.0"?>
<queryset>

<fullquery name="shipped_items_count">      
      <querytext>
      select count(*) from ec_items where order_id=:order_id and item_state in ('shipped', 'arrived', 'received_back')
      </querytext>
</fullquery>

 
</queryset>
