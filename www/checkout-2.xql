<?xml version="1.0"?>

<queryset>

  <fullquery name="get_order_id_and_order_owner">      
    <querytext>
      select order_id, 
      user_id as order_owner
      from ec_orders 
      where user_session_id=:user_session_id 
      and order_state='in_basket'
    </querytext>
  </fullquery>

  <fullquery name="get_ec_item_count">      
    <querytext>
      select count(*) 
      from ec_items
      where order_id=:order_id
    </querytext>
  </fullquery>

  <fullquery name="get_an_address_id">      
    <querytext>
      select count(*) 
      from ec_addresses
      where address_id=:address_id
      and user_id=:user_id
    </querytext>
  </fullquery>

  <fullquery name="update_ec_order_address">      
    <querytext>
      update ec_orders set shipping_address=:address_id where order_id=:order_id
    </querytext>
  </fullquery>

  <fullquery name="get_address_id">      
    <querytext>
      select shipping_address 
      from ec_orders
      where order_id=:order_id
    </querytext>
  </fullquery>

  <fullquery name="get_shipping_data">      
    <querytext>
      select p.no_shipping_avail_p, p.product_name, p.one_line_description, p.product_id,
      count(*) as quantity,
      u.offer_code,
      i.color_choice, i.size_choice, i.style_choice
      from ec_orders o
      join ec_items i on (o.order_id=i.order_id)
      join ec_products p on (i.product_id=p.product_id)
      left join (select offer_code, product_id
          from ec_user_session_offer_codes usoc
          where usoc.user_session_id=:user_session_id) u on (p.product_id = u.product_id)
      where o.user_session_id=:user_session_id and o.order_state='in_basket'
      group by p.no_shipping_avail_p, p.product_name, p.one_line_description, p.product_id, u.offer_code, i.color_choice, i.size_choice, i.style_choice
    </querytext>
  </fullquery>

</queryset>
