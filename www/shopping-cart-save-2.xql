<?xml version="1.0"?>

<queryset>

  <fullquery name="update_ec_orders">      
    <querytext>
      update ec_orders 
      set user_id=:user_id, user_session_id=null, saved_p='t'
      where user_session_id=:user_session_id
      and order_state='in_basket'
    </querytext>
  </fullquery>

</queryset>
