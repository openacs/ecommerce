<?xml version="1.0"?>
<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="get_carrier_list">      
      <querytext>
      select distinct carrier from ec_shipments where carrier is not null order by carrier
      </querytext>
</fullquery>


<partialquery name="last_24">
      <querytext>
        now()-s.shipment_date <= timespan_days(1)
      </querytext>
</partialquery>


<partialquery name="last_week">
      <querytext>
        now()-s.shipment_date <= timespan_days(7)
      </querytext>
</partialquery>


<partialquery name="last_month">
      <querytext>
        now()-s.shipment_date <= '1 month'::interval
      </querytext>
</partialquery>

 
<fullquery name="shipments_select">      
      <querytext>
      
select s.shipment_id, 
       s.shipment_date, 
       s.order_id, 
       s.carrier, 
       case when coalesce((select count(*) from ec_items where order_id=s.order_id),0) = coalesce((select count(*) from ec_items where shipment_id=s.shipment_id),0) then 'Full' else 'Partial' end as full_or_partial,
       coalesce((select count(*) from ec_items where shipment_id=s.shipment_id),0) as n_items
from ec_shipments s
$where_clause
order by $order_by_clause

      </querytext>
</fullquery>

 
</queryset>
