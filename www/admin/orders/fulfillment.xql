<?xml version="1.0"?>
<queryset>

<fullquery name="orders_select">      
      <querytext>
      
    select o.order_id, o.confirmed_date, o.order_state, o.shipping_method,
           u.first_names, u.last_name, u.user_id
      from ec_orders_shippable o, cc_users u
     where o.user_id=u.user_id
  order by o.shipping_method, o.order_state, o.order_id

      </querytext>
</fullquery>

 
</queryset>
