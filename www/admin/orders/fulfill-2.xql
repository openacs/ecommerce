<?xml version="1.0"?>
<queryset>

<fullquery name="shipping_method_select">      
      <querytext>
      
select shipping_method
  from ec_orders
 where order_id=:order_id

      </querytext>
</fullquery>

 
<fullquery name="get_pretty_mailing_address">      
      <querytext>
      select shipping_address from ec_orders where order_id=:order_id
      </querytext>
</fullquery>

 
</queryset>
