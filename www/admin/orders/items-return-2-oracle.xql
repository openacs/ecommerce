<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="unused">      
      <querytext>
      select nvl(shipping_charged,0) - nvl(shipping_refunded,0) from ec_orders where order_id=:order_id
      </querytext>
</fullquery>

 
</queryset>
