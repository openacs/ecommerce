<?xml version="1.0"?>
<queryset>

<fullquery name="get_order_id">      
      <querytext>
      select order_id from ec_orders where user_session_id=:user_session_id and order_state='in_basket'
      </querytext>
</fullquery>

 
<fullquery name="get_ec_item_count_inbasket">      
      <querytext>
      select count(*) from ec_items where order_id=:order_id
      </querytext>
</fullquery>

 
<fullquery name="get_order_owner">      
      <querytext>
      select user_id from ec_orders where order_id=:order_id
      </querytext>
</fullquery>

 
<fullquery name="get_cc_info">      
      <querytext>
      select creditcard_type, creditcard_number, creditcard_expire, billing_zip_code from 
ec_creditcards, ec_orders
where ec_creditcards.creditcard_id=ec_orders.creditcard_id
and order_id=:order_id
      </querytext>
</fullquery>

 
</queryset>
