<?xml version="1.0"?>

<queryset>
  <rdbms>
    <type>oracle</type>
    <version>8.1.6</version>
  </rdbms>

  <fullquery name="get_shipping_data">      
    <querytext>
      select p.no_shipping_avail_p, p.product_name, p.one_line_description, p.product_id, count(*) as quantity, u.offer_code, i.color_choice, i.size_choice, i.style_choice
      from ec_orders o, ec_items i, ec_products p, (select offer_code, product_id
          from ec_user_session_offer_codes usoc
          where usoc.user_session_id=:user_session_id) u
      where i.product_id=p.product_id
      and o.order_id=i.order_id
      and p.product_id= u.product_id(+)
      and o.user_session_id=:user_session_id and o.order_state='in_basket'
      group by p.no_shipping_avail_p, p.product_name, p.one_line_description, p.product_id, u.offer_code, i.color_choice, i.size_choice, i.style_choice
    </querytext>
  </fullquery>

</queryset>
