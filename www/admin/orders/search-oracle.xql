<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="order_id_query_string_sql">      
      <querytext>
      
    select o.order_id, o.confirmed_date, o.order_state,
           ec_total_price(o.order_id) as price_to_display,
           o.user_id,
           u.first_names, u.last_name,
           count(*) as n_items
      from ec_orders o, cc_users u, ec_items i
     where o.order_id like :order_id_query_string
       and o.user_id=u.user_id(+)
       and o.order_id=i.order_id
  group by o.order_id, o.confirmed_date, o.order_state,
           ec_total_price(o.order_id), o.user_id,
           u.first_names, u.last_name
  order by order_id
  
      </querytext>
</fullquery>


<fullquery name="product_sku_query_string_sql">
      <querytext>

    select o.order_id, o.confirmed_date, o.order_state,
           ec_total_price(o.order_id) as price_to_display,
           o.user_id,
           u.first_names, u.last_name,
           p.product_name,
           count(*) as n_items
      from ec_orders o, cc_users u, ec_items i, ec_products p
     where upper(p.sku) like upper(:product_sku_query_string)
       and i.product_id=p.product_id
       and o.user_id=u.user_id(+)
       and o.order_id=i.order_id
  group by o.order_id, o.confirmed_date, o.order_state,
           ec_total_price(o.order_id),
           o.user_id,
           u.first_names, u.last_name, p.product_name
  order by order_id

      </querytext>
</fullquery>


<fullquery name="product_name_query_string_sql">
      <querytext>

    select o.order_id, o.confirmed_date, o.order_state,
           ec_total_price(o.order_id) as price_to_display,
           o.user_id,
           u.first_names, u.last_name,
           p.product_name,
           count(*) as n_items
      from ec_orders o, cc_users u, ec_items i, ec_products p
     where upper(p.product_name) like upper(:product_name_query_string)
       and i.product_id=p.product_id
       and o.user_id=u.user_id(+)
       and o.order_id=i.order_id
  group by o.order_id, o.confirmed_date, o.order_state,
           ec_total_price(o.order_id),
           o.user_id,
           u.first_names, u.last_name, p.product_name
  order by order_id

      </querytext>
</fullquery>


<fullquery name="default_sql">
      <querytext>

    select o.order_id, o.confirmed_date, o.order_state,
           ec_total_price(o.order_id) as price_to_display,
           o.user_id,
           u.first_names, u.last_name,
           count(*) as n_items
      from ec_orders o, cc_users u, ec_items i
     where upper(u.last_name) like upper(:cust_last_name_query_string)
       and o.user_id=u.user_id(+)
       and o.order_id=i.order_id
  group by o.order_id, o.confirmed_date, o.order_state,
           ec_total_price(o.order_id),
           o.user_id,
           u.first_names, u.last_name
  order by order_id

      </querytext>
</fullquery>


 
</queryset>
