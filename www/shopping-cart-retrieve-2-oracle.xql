<?xml version="1.0"?>

<queryset>
  <rdbms>
    <type>oracle</type>
    <version>8.1.6</version>
  </rdbms>

  <fullquery name="get_basket_info">      
    <querytext>
      select to_char(o.in_basket_date,'Month DD, YYYY') as formatted_in_basket_date, o.in_basket_date, o.order_id, count(*) as n_products
      from ec_orders o, ec_items i
      where user_id=:user_id
      and order_state='in_basket'
      and saved_p='t'
      and i.order_id=o.order_id
      group by o.order_id, to_char(o.in_basket_date,'Month DD, YYYY'), o.in_basket_date
      order by o.in_basket_date
    </querytext>
  </fullquery>

</queryset>
