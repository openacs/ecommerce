<?xml version="1.0"?>
<queryset>

<fullquery name="user_id_select">      
      <querytext>
      
select user_id
  from ec_orders
 where order_id=:order_id
      </querytext>
</fullquery>

 
<fullquery name="shipping_method_select">      
      <querytext>
      
select shipping_method
  from ec_orders
 where order_id=:order_id

      </querytext>
</fullquery>

 
</queryset>
