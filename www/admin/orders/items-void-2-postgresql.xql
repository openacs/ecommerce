<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="gift_certificate_amount_select">      
      <querytext>
      select ec_order_gift_cert_amount(:order_id) 
      </querytext>
</fullquery>

 
<fullquery name="item_state_update">      
      <querytext>
      update ec_items set item_state='void', voided_date=current_timestamp, voided_by=:customer_service_rep where item_id in ([join $item_id_list ", "])
      </querytext>
</fullquery>

 
<fullquery name="item_state_update2">      
      <querytext>
      update ec_items set item_state='void', voided_date=current_timestamp, voided_by=:customer_service_rep where order_id=:order_id and product_id=:product_id
      </querytext>
</fullquery>

 
<fullquery name="certificate_amount_used_select">      
      <querytext>
      select ec_order_gift_cert_amount(:order_id) 
      </querytext>
</fullquery>

 
<fullquery name="problems_log_insert">      
      <querytext>
      insert into ec_problems_log
      (problem_id, problem_date, problem_details, order_id)
      values
      (ec_problem_id_sequence.nextval, current_timestamp, 'We were unable to reinstate the customer''s gift certificate balance because the amount to be reinstated was larger than the original amount used.  This shouldn''t have happened unless there was a programming error or unless the database was incorrectly updated manually.  The voiding of this order has been aborted.', :order_id)
      
      </querytext>
</fullquery>

 
<fullquery name="reinstatable_amount_select">      
      <querytext>
      select ec_one_gift_cert_on_one_order(:cert,:order_id) 
      </querytext>
</fullquery>

 
<fullquery name="reinstate_gift_certificate_insert">      
      <querytext>
      insert into ec_gift_certificate_usage
	    (gift_certificate_id, order_id, amount_reinstated, reinstated_date)
	    values
	    (:cert, :order_id, :iteration_reinstate_amount, current_timestamp)
	    
      </querytext>
</fullquery>

 
</queryset>
