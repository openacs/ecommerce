<?xml version="1.0"?>

<queryset>
  <rdbms><type>postgresql</type><version>7.1</version></rdbms>

  <partialquery name="last_24">      
    <querytext>
      where now()-o.in_basket_date <= timespan_days(1)
    </querytext>
  </partialquery>

  <partialquery name="last_week">      
    <querytext>
      where now()-o.in_basket_date <= timespan_days(7)
    </querytext>
  </partialquery>

  <partialquery name="last_month">      
    <querytext>
      where now()-o.in_basket_date <= '1 month'::interval
    </querytext>
  </partialquery>
  
  <partialquery name="all">
    <querytext>
      where true
    </querytext>
  </partialquery>

  <fullquery name="orders_select">      
    <querytext>
      select o.order_id, o.in_basket_date, o.order_state, ec_total_price(o.order_id) as price_to_display, o.user_id, u.first_names, u.last_name, count(*) as n_items
      from ec_orders o
      join ec_items i using (order_id)
      left join cc_users u on (o.user_id=u.user_id)
      $confirmed_query_bit 
      $order_state_query_bit
      group by o.order_id, o.in_basket_date, o.order_state, ec_total_price(o.order_id), o.user_id, u.first_names, u.last_name
      order by $order_by_clause
    </querytext>
  </fullquery>

</queryset>
