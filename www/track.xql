<?xml version="1.0"?>
<queryset>

<fullquery name="assure_order_is_this_user">      
      <querytext>
      select user_id from ec_orders o, ec_shipments s
where o.order_id = s.order_id
and s.shipment_id = :shipment_id
      </querytext>
</fullquery>

 
</queryset>
