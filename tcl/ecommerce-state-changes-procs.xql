<?xml version="1.0"?>
<queryset>

<fullquery name="ec_update_state_to_in_basket.credit_user_select">      
      <querytext>
      select creditcard_id, user_id from ec_orders where order_id=:order_id
      </querytext>
</fullquery>

 
<fullquery name="ec_update_state_to_in_basket.order_state_update">      
      <querytext>
      update ec_orders set order_state='in_basket', confirmed_date=null where order_id=:order_id
      </querytext>
</fullquery>

 
<fullquery name="ec_update_state_to_in_basket.creditcard_update">      
      <querytext>
      update ec_creditcards set failed_p='t' where creditcard_id=:creditcard_id
      </querytext>
</fullquery>

 
<fullquery name="ec_update_state_to_authorized.transaction_select">      
      <querytext>
      select max(transaction_id) from ec_financial_transactions where order_id=:order_id
      </querytext>
</fullquery>

 
<fullquery name="ec_update_state_to_in_basket.order_state_update">      
      <querytext>
      update ec_orders set order_state='in_basket', confirmed_date=null where order_id=:order_id
      </querytext>
</fullquery>

 
<fullquery name="ec_update_state_to_authorized.set_to_be_shipped">      
      <querytext>
      update ec_items set item_state='to_be_shipped' where order_id=:order_id
      </querytext>
</fullquery>

 
<fullquery name="ec_update_state_to_confirmed.user_id_select">      
      <querytext>
      select user_id from ec_orders where order_id=:order_id
      </querytext>
</fullquery>

 
<fullquery name="ec_update_state_to_in_basket.order_state_update">      
      <querytext>
      update ec_orders set order_state='in_basket', confirmed_date=null where order_id=:order_id
      </querytext>
</fullquery>

 
</queryset>
