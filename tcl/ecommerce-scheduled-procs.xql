<?xml version="1.0"?>
<queryset>

<fullquery name="ec_calculate_product_purchase_combinations.products_select">      
      <querytext>
      select product_id from ec_products
      </querytext>
</fullquery>

 
<fullquery name="ec_calculate_product_purchase_combinations.correlated_products_select">      
      <querytext>
      
	    select i2.product_id as correlated_product_id,
	           count(*) as n_product_occurrences
	      from ec_items i2
	     where i2.order_id in (select o2.order_id
				     from ec_orders o2
				    where o2.user_id in (select user_id
							   from ec_orders o
							  where o.order_id in (select i.order_id
									         from ec_items i
									        where product_id = :product_id)))
	       and i2.product_id <> :product_id
	     group by i2.product_id
	     order by n_product_occurrences desc
	
      </querytext>
</fullquery>

 
<fullquery name="ec_calculate_product_purchase_combinations.product_purchase_comb_select">      
      <querytext>
      select count(*) from ec_product_purchase_comb where product_id=:product_id
      </querytext>
</fullquery>

 
<fullquery name="ec_calculate_product_purchase_combinations.product_purchase_comb_insert">      
      <querytext>
      
		    insert into ec_product_purchase_comb
		    (product_id, [join $insert_cols ", "])
		    values
		    (:product_id, [join $insert_vals ", "])
		
      </querytext>
</fullquery>

 
<fullquery name="ec_calculate_product_purchase_combinations.product_purchase_comb_update">      
      <querytext>
      
		    update ec_product_purchase_comb
		    set [join $update_items ", "]
		    where product_id=:product_id
		
      </querytext>
</fullquery>

 
<fullquery name="ec_sweep_for_cybercash_zombies.transaction_id_select">      
      <querytext>
      
	      select max(transaction_id)
	      from ec_financial_transactions
	      where order_id = :order_id
	  
      </querytext>
</fullquery>

 
<fullquery name="ec_sweep_for_cybercash_zombies.avs_code_select">      
      <querytext>
      
		  select avs_code 
		    from ec_cybercash_log
		   where transaction_id = :transaction_id 
		     and avs_code != ''
		     and txn_attempted_time = (select MAX(txn_attempted_time)
					         from ec_cybercash_log log2
					        where log2.transaction_id = :transaction_id)
	      
      </querytext>
</fullquery>

 
<fullquery name="ec_sweep_for_cybercash_zombies.order_state_update">      
      <querytext>
      update ec_orders set order_state=:new_order_state where order_id=:order_id
      </querytext>
</fullquery>

 
<fullquery name="ec_sweep_for_cybercash_zombie_gift_certificates.transaction_id_select">      
      <querytext>
      select transaction_id from ec_financial_transactions where gift_certificate_id=:gift_certificate_id
      </querytext>
</fullquery>

 
<fullquery name="ec_sweep_for_cybercash_zombie_gift_certificates.financial_transactions_update_1">      
      <querytext>
      update ec_financial_transactions set failed_p='t', to_be_captured_p='f' where transaction_id=:transaction_id
      </querytext>
</fullquery>

 
<fullquery name="ec_sweep_for_cybercash_zombie_gift_certificates.gift_certificate_state_update_1">      
      <querytext>
      update ec_gift_certificates set gift_certificate_state='failed_authorization' where gift_certificate_id=:gift_certificate_id
      </querytext>
</fullquery>

 
<fullquery name="ec_send_unsent_new_order_email.unsent_orders_select">      
      <querytext>
      
	select order_id
	from ec_orders o
	where (order_state='authorized_plus_avs' or order_state='authorized_minus_avs')
	and (0=(select count(*) from ec_automatic_email_log log where log.order_id=o.order_id and email_template_id=1))
    
      </querytext>
</fullquery>

 
<fullquery name="ec_send_unsent_new_gift_certificate_order_email.unsent_gift_certificate_email">      
      <querytext>
      
	select gift_certificate_id
	from ec_gift_certificates g
	where (gift_certificate_state='authorized_plus_avs' or gift_certificate_state='authorized_minus_avs')
	and (0=(select count(*) from ec_automatic_email_log log where log.gift_certificate_id=g.gift_certificate_id and email_template_id=4))
    
      </querytext>
</fullquery>

 
<fullquery name="ec_send_unsent_gift_certificate_recipient_email.unsent_gift_certificate_select">      
      <querytext>
      
	select gift_certificate_id
	from ec_gift_certificates g
	where (gift_certificate_state='authorized_plus_avs' or gift_certificate_state='authorized_minus_avs')
	and (0=(select count(*) from ec_automatic_email_log log where log.gift_certificate_id=g.gift_certificate_id and email_template_id=5))
    
      </querytext>
</fullquery>

 
<fullquery name="ec_delayed_credit_denied.denied_orders_select">      
      <querytext>
      select order_id from ec_orders where order_state='failed_authorization'
      </querytext>
</fullquery>

 
<fullquery name="ec_delayed_credit_denied.order_state_update">      
      <querytext>
      update ec_orders set order_state='in_basket', saved_p='t' where order_id=:order_id
      </querytext>
</fullquery>

 
<fullquery name="ec_remove_creditcard_data.creditcard_update">      
      <querytext>
      
	    update ec_creditcards
	    set creditcard_number=null
	    where creditcard_id in (select unique c.creditcard_id
				    from ec_creditcards c, ec_orders o
				    where c.creditcard_id = o.creditcard_id
				    and c.creditcard_number is not null
				    and 0=(select count(*)
					   from ec_orders o2
					   where o2.creditcard_id=c.creditcard_id
					   and o2.order_state not in ('fulfilled','returned','void','expired')))
	
      </querytext>
</fullquery>

 
<fullquery name="ec_unauthorized_transactions.transaction_failed_update">      
      <querytext>
      update ec_financial_transactions set failed_p='t' where transaction_id=:transaction_id
      </querytext>
</fullquery>

 
<fullquery name="ec_unmarked_transactions.unmarked_transactions_select">      
      <querytext>
      
	select transaction_id, order_id from ec_financial_transactions
	where to_be_captured_p='t'
	and authorized_date is not null
	and marked_date is null
	and failed_p='f'
    
      </querytext>
</fullquery>

 
<fullquery name="ec_unmarked_transactions.financial_transaction_failed_update">      
      <querytext>
      update ec_financial_transactions set failed_p='t' where transaction_id=:transaction_id
      </querytext>
</fullquery>

 
<fullquery name="ec_unmarked_transactions.financial_transactions_update">      
      <querytext>
      financial_transactions set marked_date=sysdate where transaction_id=:transaction_id
      </querytext>
</fullquery>

 
<fullquery name="ec_unsettled_transactions.unsettled_transactions_select">      
      <querytext>
      
	select transaction_id, order_id from ec_financial_transactions
	where marked_date is not null
	and settled_date is null
	and failed_p='f'
    
      </querytext>
</fullquery>

 
<fullquery name="ec_unsettled_transactions.transaction_failed_update">      
      <querytext>
      update ec_financial_transactions set failed_p='t' where transaction_id=:transaction_id
      </querytext>
</fullquery>

 
<fullquery name="ec_unmarked_transactions.financial_transaction_failed_update">      
      <querytext>
      update ec_financial_transactions set failed_p='t' where transaction_id=:transaction_id
      </querytext>
</fullquery>

 
<fullquery name="ec_unrefund_settled_transactions.unrefund_settled_transactions_select">      
      <querytext>
      select transaction_id, order_id from ec_financial_transactions
  where refunded_date is not null
  and refund_settled_date is null
  and failed_p='f'
      </querytext>
</fullquery>

 
<fullquery name="ec_unauthorized_transactions.transaction_failed_update">      
      <querytext>
      update ec_financial_transactions set failed_p='t' where transaction_id=:transaction_id
      </querytext>
</fullquery>

 
</queryset>
