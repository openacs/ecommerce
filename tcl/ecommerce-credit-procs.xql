<?xml version="1.0"?>

<queryset>

  <fullquery name="ec_creditcard_authorization.order_data_select">      
    <querytext>
      select ec_order_cost(:order_id) as total_amount, creditcard_id
      from ec_orders
      where order_id = :order_id
    </querytext>
  </fullquery>
  
  <fullquery name="ec_creditcard_authorization.transaction_data_select">      
    <querytext>
      select transaction_amount as total_amount, creditcard_id
      from ec_financial_transactions
      where transaction_id = :transaction_id
    </querytext>
  </fullquery>
  
  <fullquery name="ec_creditcard_authorization.update_transaction_id">
    <querytext>
      update ec_financial_transactions 
      set transaction_id = :pgw_transaction_id
      where transaction_id = :transaction_id
    </querytext>
  </fullquery>

  <fullquery name="ec_creditcard_marking.update_transaction_id">
    <querytext>
      update ec_financial_transactions 
      set transaction_id = :pgw_transaction_id
      where transaction_id = :transaction_id
    </querytext>
  </fullquery>

  <fullquery name="ec_creditcard_return.transaction_failure_update">
    <querytext>
      update ec_financial_transactions 
      set failed_p = 't'
      where transaction_id = :transaction_id
    </querytext>
  </fullquery>
  
</queryset>
