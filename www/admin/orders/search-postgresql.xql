<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="order_id_query_string_sql">      
      <querytext>
      
    select o.order_id, o.confirmed_date, o.order_state,
           ec_total_price(o.order_id) as price_to_display,
           o.user_id,
           u.first_names, u.last_name,
           count(*) as n_items
      from ec_orders o
           LEFT JOIN cc_users u on (o.user_id=u.user_id)
           JOIN ec_items i on (o.order_id=i.order_id)
     where o.order_id like :order_id_query_string
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
      from ec_orders o
           JOIN ec_items i on (o.order_id=i.order_id)
           JOIN ec_products p on (i.product_id=p.product_id)
           LEFT JOIN cc_users u on (o.user_id=u.user_id)
     where upper(p.sku) like upper(:product_sku_query_string)
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
      from ec_orders o
           JOIN ec_items i on (o.order_id=i.order_id)
           JOIN ec_products p on (i.product_id=p.product_id)
           LEFT JOIN cc_users u on (o.user_id=u.user_id)
     where upper(p.product_name) like upper(:product_name_query_string)
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
      from ec_orders o
           LEFT JOIN cc_users u on (o.user_id=u.user_id)
	   JOIN ec_items i on (o.order_id=i.order_id)
     where upper(u.last_name) like upper(:cust_last_name_query_string)
  group by o.order_id, o.confirmed_date, o.order_state,
           ec_total_price(o.order_id),
           o.user_id,
           u.first_names, u.last_name
  order by order_id

      </querytext>
</fullquery>


 
</queryset>
