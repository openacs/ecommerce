<?xml version="1.0"?>

<queryset>
  <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

  <partialquery name="last_24">
    <querytext>
      and sysdate-o.in_basket_date <= 1
    </querytext>
  </partialquery>

  <partialquery name="last_week">
    <querytext>
      and sysdate-o.in_basket_date <= 7
    </querytext>
  </partialquery>

  <partialquery name="last_month">
    <querytext>
      and months_between(sysdate,o.in_basket_date) <= 1
    </querytext>
  </partialquery>

  <partialquery name="all">
    <querytext>
      and 1=1
    </querytext>
  </partialquery>

  <fullquery name="orders_select">      
    <querytext>
      select o.order_id, o.in_basket_date, o.order_state, ec_total_price(o.order_id) as price_to_display, o.user_id, u.first_names, u.last_name, count(*) as n_items
      from ec_orders o, ec_items i, cc_users u
      where o.order_id=i.order_id
      and o.user_id(+)=u.user_id
      $confirmed_query_bit 
      $order_state_query_bit
      group by o.order_id, o.in_basket_date, o.order_state, ec_total_price(o.order_id), o.user_id, u.first_names, u.last_name
      order by $order_by_clause
    </querytext>
  </fullquery>

</queryset>
