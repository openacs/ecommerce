<?xml version="1.0"?>

<queryset>

  <fullquery name="get_n_confirmed_orders">      
    <querytext>
      select count(*) 
      from ec_orders
      where user_session_id=:user_session_id
      and order_state='confirmed'
    </querytext>
  </fullquery>

  <fullquery name="get_order_id">      
    <querytext>
      select order_id
      from ec_orders
      where user_session_id=:user_session_id
      and order_state='in_basket'
    </querytext>
  </fullquery>

</queryset>
