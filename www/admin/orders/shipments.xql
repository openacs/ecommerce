<?xml version="1.0"?>
<queryset>

<fullquery name="get_carrier_list">      
      <querytext>
      select unique carrier from ec_shipments where carrier is not null order by carrier
      </querytext>
</fullquery>

 
<fullquery name="shipments_select">      
      <querytext>
      
select s.shipment_id, 
       s.shipment_date, 
       s.order_id, 
       s.carrier, 
       case when coalesce((select count(*) from ec_items where order_id=s.order_id) = 0) then coalesce((select count(*) from ec_items where shipment_id=s.shipment_id) else 0 end,'Full','Partial') as full_or_partial,
       coalesce((select count(*) from ec_items where shipment_id=s.shipment_id),0) as n_items
from ec_shipments s
$where_clause
order by $order_by_clause
      </querytext>
</fullquery>

 
</queryset>
