<?xml version="1.0"?>

<queryset>

  <fullquery name="orders_select">      
    <querytext>
      select o.order_id, o.confirmed_date, o.order_state, ec_total_price(o.order_id) as price_to_display, o.user_id, u.first_names, u.last_name, count(*) as n_items
      from ec_orders o
      join ec_items i using (order_id)
      left join cc_users u on (o.user_id=u.user_id)
      $confirmed_query_bit 
      $order_state_query_bit
      group by o.order_id, o.confirmed_date, o.order_state, ec_total_price(o.order_id), o.user_id, u.first_names, u.last_name
      order by $order_by_clause
    </querytext>
  </fullquery>
  
</queryset>
