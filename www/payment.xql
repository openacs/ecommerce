<?xml version="1.0"?>

<queryset>

  <fullquery name="get_order_id_and_order_owner">      
    <querytext>
      select order_id, shipping_address as address_id, user_id as order_owner
      from ec_orders 
      where user_session_id=:user_session_id 
      and order_state='in_basket'
    </querytext>
  </fullquery>

  <fullquery name="get_ec_item_cart_count">      
    <querytext>
      select count(*) 
      from ec_items
      where order_id=:order_id
    </querytext>
  </fullquery>

  <fullquery name="get_creditcards_onfile">      
    <querytext>
      select c.creditcard_id, c.creditcard_type, c.creditcard_last_four, c.creditcard_expire
      from ec_creditcards c
      where c.user_id=:user_id
      and c.creditcard_number is not null
      and c.failed_p='f'
      and 0 < (select count(*) from ec_orders o where o.creditcard_id = c.creditcard_id)
      order by c.creditcard_id desc
    </querytext>
  </fullquery>

</queryset>
