<?xml version="1.0"?>

<queryset>
  <rdbms>
    <type>oracle</type>
    <version>8.1.6</version>
  </rdbms>

  <fullquery name="get_products_in_cart">      
    <querytext>
      select p.product_name, p.one_line_description, p.product_id, count(*) as quantity, u.offer_code, i.color_choice, i.size_choice, i.style_choice
      from ec_orders o, ec_items i, ec_products p, 
      (select product_id, offer_code from ec_user_session_offer_codes usoc where usoc.user_session_id=:user_session_id) u
      where i.product_id=p.product_id
      and o.order_id=i.order_id
      and p.product_id=u.product_id(+)
      and o.user_session_id=:user_session_id and o.order_state='in_basket'
      group by p.product_name, p.one_line_description, p.product_id, u.offer_code, i.color_choice, i.size_choice, i.style_choice
    </querytext>
  </fullquery>

  <fullquery name="check_for_saved_carts">      
    <querytext>
      select 1 
      from dual 
      where exists (select 1 
          from ec_orders 
          where user_id=:user_id 
          and order_state='in_basket' 
          and saved_p='t')
    </querytext>
  </fullquery>

</queryset>
