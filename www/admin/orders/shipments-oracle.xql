<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="shipments_select">      
      <querytext>
      
select s.shipment_id, 
       s.shipment_date, 
       s.order_id, 
       s.carrier, 
       case when nvl((select count(*) from ec_items where order_id=s.order_id) = 0) then nvl((select count(*) from ec_items where shipment_id=s.shipment_id) else 0 end,'Full','Partial') as full_or_partial,
       nvl((select count(*) from ec_items where shipment_id=s.shipment_id),0) as n_items
from ec_shipments s
$where_clause
order by $order_by_clause
      </querytext>
</fullquery>

 
</queryset>
