<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="get_new_creditcard_id">      
      <querytext>
      select creditcard_id_sequence.nextval from dual
      </querytext>
</fullquery>

 
<fullquery name="insert_new_ec_refund">      
      <querytext>
      insert into ec_refunds
    (refund_id, order_id, refund_amount, refund_date, refunded_by, refund_reasons)
    values
    (:refund_id, :order_id, :cash_amount_to_refund, sysdate, :customer_service_rep,:reason_for_return)
    
      </querytext>
</fullquery>

 
<fullquery name="get_tax_charged_on_item">      
      <querytext>
      select nvl(price_tax_charged,0) as price_tax_charged, nvl(shipping_tax_charged,0) as shipping_tax_charged from ec_items where item_id=:item_id
      </querytext>
</fullquery>

 
<fullquery name="get_tax_charged">      
      <querytext>
      select ec_tax(:price_bind_variable,0,:order_id) from dual
      </querytext>
</fullquery>

 
<fullquery name="get_tax_shipping_to_refund">      
      <querytext>
      select ec_tax(0,:shipping_bind_variable,:order_id) from dual
      </querytext>
</fullquery>

 
<fullquery name="get_base_shipping_tax">      
      <querytext>
      select nvl(shipping_tax_charged,0) from ec_orders where order_id=:order_id
      </querytext>
</fullquery>

 
<fullquery name="get_base_tax_to_refund">      
      <querytext>
      select ec_tax(0,:base_shipping_to_refund,:order_id) from dual
      </querytext>
</fullquery>

 
<fullquery name="get_new_trans_id">      
      <querytext>
      select ec_transaction_id_sequence.nextval from dual
      </querytext>
</fullquery>

 
<fullquery name="insert_new_financial_trans">      
      <querytext>
      insert into ec_financial_transactions
	(transaction_id, order_id, refund_id, creditcard_id, transaction_amount, transaction_type, inserted_date)
	values
	(:transaction_id, :order_id, :refund_id, :creditcard_id, :cash_amount_to_refund, 'refund', sysdate)
	
      </querytext>
</fullquery>

 
<fullquery name="get_gc_amount_used">      
      <querytext>
      select ec_order_gift_cert_amount(:order_id) from dual
      </querytext>
</fullquery>

 
<fullquery name="insert_too_little_gc">      
      <querytext>
      insert into ec_problems_log
	    (problem_id, problem_date, problem_details, order_id)
	    values
	    (ec_problem_id_sequence.nextval, sysdate, :errorstring, :order_id)
	    
      </querytext>
</fullquery>

 
<fullquery name="get_gc_amt_left">      
      <querytext>
      select gift_certificate_amount_left(:cert) from dual
      </querytext>
</fullquery>

 
<fullquery name="insert_new_gc_usage_reinstate">      
      <querytext>
      insert into ec_gift_certificate_usage
			(gift_certificate_id, order_id, amount_reinstated, reinstated_date)
			values
			(:cert, :order_id, :iteration_reinstate_amount, sysdate)
			
      </querytext>
</fullquery>

 
<fullquery name="insert_cc_refund_problem">      
      <querytext>
      insert into ec_problems_log
	(problem_id, problem_date, problem_details, order_id)
	values
	(ec_problem_id_sequence.nextval, sysdate, :errorstring, :order_id)
	
      </querytext>
</fullquery>

 
<fullquery name="update_ft_set_success">      
      <querytext>
      update ec_financial_transactions set refunded_date=sysdate where transaction_id=:transaction_id
      </querytext>
</fullquery>

 
</queryset>
