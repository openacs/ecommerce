<?xml version="1.0"?>

<queryset>
  <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

  <fullquery name="ec_creditcard_authorization.order_data_select">      
    <querytext>
      select ec_order_cost(:order_id) as total_amount, creditcard_id, case when sign(sysdate - confirmed_date - .95) = -1 then 1 else 0 end as youth
      from ec_orders
      where order_id = :order_id
    </querytext>
  </fullquery>
  
  <fullquery name="ec_creditcard_authorization.transaction_data_select">      
    <querytext>
      select transaction_amount as total_amount, creditcard_id, case when sign(sysdate-inserted_date-.95) = -1 then 1 else 0 end as youth
      from ec_financial_transactions
      where transaction_id = :transaction_id
    </querytext>
  </fullquery>
  
  <fullquery name="ec_talk_to_cybercash.cybercash_log_insert">      
    <querytext>
      insert into ec_cybercash_log 
      ([join [ad_ns_set_keys -exclude "cc_time" $bind_vars] ", "], cc_time, txn_attempted_time)
      values 
      ([join [ad_ns_set_keys -exclude "cc_time" -colon $bind_vars] ", "], to_date(:cc_time, 'YYYYMMDDHH24MISS'), sysdate)
    </querytext>
  </fullquery>
  
  <fullquery name="ec_date_to_cybercash_date_for_query.cybercash_date_create">      
    <querytext>
      select to_char(:n_hours_to_add / 24 + to_date(:the_date, 'YYYY-MM-DD HH24:MI:SS'), 'YYYYMMDDHH24MISS') 
      from dual
    </querytext>
  </fullquery>

  <fullquery name="ec_creditcard_return.transaction_success_update">
    <querytext>
      update ec_financial_transactions
      set transaction_id = :pgw_transaction_id, refunded_date = sysdate
      where transaction_id = :transaction_id
    </querytext>
  </fullquery>
  
</queryset>
