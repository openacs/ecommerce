<?xml version="1.0"?>

<queryset>
  <rdbms>
    <type>oracle</type>
    <version>8.1.6</version>
  </rdbms>

  <fullquery name="ec_update_state_to_in_basket.reinst_gift_cert_on_order">      
    <querytext>
      declare 
      begin 
          ec_reinst_gift_cert_on_order (:order_id); 
      end;
    </querytext>
  </fullquery>
  
  <fullquery name="ec_update_state_to_authorized.order_cost_select">      
    <querytext>
      select ec_order_cost(:order_id) 
      from dual
    </querytext>
  </fullquery>

  <fullquery name="ec_update_state_to_authorized.order_state_update">
    <querytext>
      update ec_orders 
      set order_state='authorized', authorized_date=sysdate 
      where order_id=:order_id
    </querytext>
  </fullquery>
  
  <fullquery name="ec_update_state_to_authorized.authorized_date_update">      
    <querytext>
      update ec_financial_transactions 
      set authorized_date=sysdate 
      where transaction_id=:transaction_id
    </querytext>
  </fullquery>

  <fullquery name="ec_update_state_to_confirmed.order_state_update">
    <querytext>
      update ec_orders 
      set order_state='confirmed', confirmed_date=sysdate 
      where order_id=:order_id
    </querytext>
  </fullquery>
  
  <fullquery name="ec_update_state_to_confirmed.total_amount_select">      
    <querytext>
      select ec_order_cost(:order_id) 
      from dual
    </querytext>
  </fullquery>
  
  <fullquery name="ec_update_state_to_confirmed.financial_transaction_insert">      
    <querytext>
      insert into ec_financial_transactions
      (transaction_id, order_id, transaction_amount, transaction_type, inserted_date)
      values
      (:transaction_id, :order_id, :total_amount, 'charge', sysdate)
    </querytext>
  </fullquery>
  
  <fullquery name="ec_apply_gift_certificate_balance.amount_owed_select">      
    <querytext>
      select ec_order_amount_owed(:order_id) 
      from dual
    </querytext>
  </fullquery>
  
  <fullquery name="ec_apply_gift_certificate_balance.available_gift_certificates">      
    <querytext>
      select gift_certificate_id, gift_certificate_amount_left(gift_certificate_id) as amount_available
      from ec_gift_certificates_approved
      where user_id = :user_id
      and sysdate - expires < 0
      and amount_remaining_p = 't'
      and gift_certificate_amount_left(gift_certificate_id) > 0
      order by expires
    </querytext>
  </fullquery>
  
  <fullquery name="ec_apply_gift_certificate_balance.gift_certificate_usage_insert">      
    <querytext>
      insert into ec_gift_certificate_usage
      (gift_certificate_id, order_id, amount_used, used_date)
      values
      (:gift_certificate_id, :order_id, least(to_number(:amount_available), to_number(:amount_owed)), sysdate)
    </querytext>
  </fullquery>
  
</queryset>
