<?xml version="1.0"?>

<queryset>
  <rdbms>
    <type>postgresql</type>
    <version>7.1</version>
  </rdbms>

  <fullquery name="get_products_in_cart">      
    <querytext>
      select p.product_name, p.one_line_description, p.product_id, count(*) as quantity, u.offer_code, i.color_choice, i.size_choice, i.style_choice, '' as price 
      from ec_orders o
      join ec_items i on (o.order_id=i.order_id)
      join ec_products p on (i.product_id=p.product_id)
      left join (select product_id, offer_code 
	  from ec_user_session_offer_codes usoc 
	  where usoc.user_session_id=:user_session_id) u on (p.product_id=u.product_id)
      where o.user_session_id=:user_session_id 
      and o.order_state='in_basket'
      group by p.product_name, p.one_line_description, p.product_id, u.offer_code, i.color_choice, i.size_choice, i.style_choice
    </querytext>
  </fullquery>

</queryset>
