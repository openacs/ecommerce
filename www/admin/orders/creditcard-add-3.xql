<?xml version="1.0"?>
<queryset>

  <fullquery name="user_id_select">      
    <querytext>
      select user_id 
      from ec_orders 
      where order_id = :order_id
    </querytext>
  </fullquery>
  
  <fullquery name="creditcard_insert_select">      
    <querytext>
      insert into ec_creditcards
      (creditcard_id, user_id, creditcard_number, creditcard_last_four, creditcard_type, creditcard_expire, billing_address)
      values
      (:creditcard_id, :user_id, :creditcard_number, :creditcard_last_four, :creditcard_type, :creditcard_expire, :address_id)
    </querytext>
  </fullquery>

  <fullquery name="ec_orders_update">      
    <querytext>
      update ec_orders 
      set creditcard_id = :creditcard_id 
      where order_id = :order_id
    </querytext>
  </fullquery>
  
</queryset>
