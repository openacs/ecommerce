<?xml version="1.0"?>

<queryset>

  <fullquery name="get_order_id">      
    <querytext>
      select order_id 
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

  <fullquery name="get_order_owner">      
    <querytext>
      select user_id 
      from ec_orders
      where order_id=:order_id
    </querytext>
  </fullquery>

  <fullquery name="get_address_id">      
    <querytext>
      select shipping_address 
      from ec_orders
      where order_id=$order_id
    </querytext>
  </fullquery>

  <fullquery name="get_creditcard_id">      
    <querytext>
      select creditcard_id 
      from ec_orders
      where order_id=:order_id
    </querytext>
  </fullquery>

  <fullquery name="get_shipping_method">      
    <querytext>
      select shipping_method 
      from ec_orders
      where order_id=:order_id
    </querytext>
  </fullquery>

</queryset>
