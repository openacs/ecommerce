<?xml version="1.0"?>
<queryset>

<fullquery name="ec_creditcard_authorization.creditcard_data_select">      
      <querytext>
      
	    select creditcard_number, creditcard_expire,
	           billing_zip_code
	      from ec_creditcards
	     where creditcard_id = :creditcard_id
	
      </querytext>
</fullquery>

 
<fullquery name="ec_creditcard_authorization.latest_transaction_select">      
      <querytext>
      
		select max(transaction_id) from ec_financial_transactions where order_id = :order_id
	    
      </querytext>
</fullquery>

 
<fullquery name="ec_creditcard_marking.transaction_amount_select">      
      <querytext>
      
	select transaction_amount from ec_financial_transactions where transaction_id = :transaction_id
    
      </querytext>
</fullquery>

 
<fullquery name="ec_creditcard_return.transaction_info_select">      
      <querytext>
      
	    select t.transaction_amount,
	           c.creditcard_number,
	           c.creditcard_expire,
	           c.billing_zip_code
	      from ec_financial_transactions t,
	           ec_creditcards c
	     where t.transaction_id = :transaction_id
	       and c.creditcard_id = t.creditcard_id
	
      </querytext>
</fullquery>

 
</queryset>
