<?xml version="1.0"?>
<queryset>

<fullquery name="get_order_id">      
      <querytext>
      select order_id from ec_orders where user_session_id=:user_session_id and order_state='in_basket'
      </querytext>
</fullquery>

 
<fullquery name="get_shopping_cart_no">      
      <querytext>
      select count(*) from ec_items where order_id=:order_id
      </querytext>
</fullquery>

 
<fullquery name="get_order_owner">      
      <querytext>
      select user_id from ec_orders where order_id=:order_id
      </querytext>
</fullquery>

 
<fullquery name="get_address_id">      
      <querytext>
      select shipping_address from ec_orders where order_id=:order_id
      </querytext>
</fullquery>

 
<fullquery name="get_shipping_method">      
      <querytext>
      select shipping_method from ec_orders where order_id=:order_id
      </querytext>
</fullquery>

 
<fullquery name="get_cc_owner">      
      <querytext>
      select user_id from ec_creditcards where creditcard_id=:creditcard_id
      </querytext>
</fullquery>

 
<fullquery name="use_existing_cc_for_order">      
      <querytext>
      update ec_orders set creditcard_id=:creditcard_id where order_id=:order_id
      </querytext>
</fullquery>

 
<fullquery name="insert_new_cc">      
      <querytext>
      insert into ec_creditcards
	(creditcard_id, user_id, creditcard_number, creditcard_last_four, creditcard_type, creditcard_expire, billing_zip_code)
	values
	(:creditcard_id, :user_id, :creditcard_number,:cc_no , :creditcard_type,:expiry,:billing_zip_code)
	
      </querytext>
</fullquery>

 
<fullquery name="update_order_set_cc">      
      <querytext>
      update ec_orders set creditcard_id=:creditcard_id where order_id=:order_id
      </querytext>
</fullquery>

 
<fullquery name="set_null_cc_in_order">      
      <querytext>
      update ec_orders set creditcard_id=null where order_id=:order_id
      </querytext>
</fullquery>

 
</queryset>
