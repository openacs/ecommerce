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

  <fullquery name="get_mrc_order">      
    <querytext>
      select order_id 
      from ec_orders
      where user_id=:user_id
      and confirmed_date is not null
      and order_id=(select max(o2.order_id)
          from ec_orders o2
          where o2.user_id=:user_id
          and o2.confirmed_date is not null)
    </querytext>
  </fullquery>

  <fullquery name="get_in_basket_count">      
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

  <fullquery name="get_a_shipping_address">      
    <querytext>
      select shipping_address 
      from ec_orders
      where order_id=:order_id
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

  <fullquery name="set_transaction_failed">
    <querytext>
      update ec_financial_transactions
      set failed_p = 't'
      where transaction_id = :transaction_id"
    </querytext>
  </fullquery>

  <fullquery name="set_transaction_failed">
    <querytext>
      update ec_financial_transactions
      set failed_p = 't'
      where transaction_id = :transaction_id
    </querytext>
  </fullquery>

</queryset>
