<?xml version="1.0"?>
<queryset>

<fullquery name="get_order_id_from_basket">      
      <querytext>
      select order_id from ec_orders where user_session_id=:user_session_id and order_state='in_basket'
      </querytext>
</fullquery>

 
<fullquery name="get_mrc_order">      
      <querytext>
      select order_id from ec_orders where user_id=:user_id and confirmed_date is not null and order_id=(select max(o2.order_id) from ec_orders o2 where o2.user_id=:user_id and o2.confirmed_date is not null)
      </querytext>
</fullquery>

 
<fullquery name="get_ec_item_count">      
      <querytext>
      select count(*) from ec_items where order_id=:order_id
      </querytext>
</fullquery>

 
<fullquery name="get_order_owner">      
      <querytext>
      select user_id from ec_orders where order_id=:order_id
      </querytext>
</fullquery>

 
<fullquery name="insert_new_creditcard">      
      <querytext>
      insert into ec_creditcards
(creditcard_id, user_id, creditcard_number, creditcard_last_four, creditcard_type, creditcard_expire, billing_zip_code)
values
(:creditcard_id, :user_id, :creditcard_number,:cc_fmt , :creditcard_type,:expiry,:billing_zip_code)

      </querytext>
</fullquery>

 
<fullquery name="update_order_cc_info">      
      <querytext>
      update ec_orders set creditcard_id=:creditcard_id where order_id=:order_id and order_state='in_basket'
      </querytext>
</fullquery>

 
</queryset>
