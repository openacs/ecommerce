<?xml version="1.0"?>
<queryset>

<fullquery name="get_refund_count">      
      <querytext>
      select count(*) from ec_refunds where refund_id=:refund_id
      </querytext>
</fullquery>

 
<fullquery name="unused">      
      <querytext>
      select coalesce(shipping_charged,0) - coalesce(shipping_refunded,0) from ec_orders where order_id=:order_id
      </querytext>
</fullquery>

 
</queryset>
