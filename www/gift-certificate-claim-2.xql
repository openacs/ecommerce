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

  <fullquery name="get_gc_id">      
    <querytext>
      select gift_certificate_id 
      from ec_gift_certificates 
      where claim_check=:claim_check
    </querytext>
  </fullquery>

  <fullquery name="get_gc_user_id">      
    <querytext>
      select user_id as gift_certificate_user_id, amount 
      from ec_gift_certificates 
      where gift_certificate_id=:gift_certificate_id
    </querytext>
  </fullquery>

</queryset>
