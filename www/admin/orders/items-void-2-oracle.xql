<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="gift_certificate_amount_select">      
      <querytext>
      select ec_order_gift_cert_amount(:order_id) from dual
      </querytext>
</fullquery>

 
<fullquery name="item_state_update">      
      <querytext>
      update ec_items set item_state='void', voided_date=sysdate, voided_by=:customer_service_rep where item_id in ([join $item_id_list ", "])
      </querytext>
</fullquery>

 
<fullquery name="item_state_update2">      
      <querytext>
      update ec_items set item_state='void', voided_date=sysdate, voided_by=:customer_service_rep where order_id=:order_id and product_id=:product_id
      </querytext>
</fullquery>

 
<fullquery name="amount_charged_minus_refunded_for_nonvoid_items_select">      
      <querytext>
      select nvl(sum(nvl(price_charged,0)) + sum(nvl(shipping_charged,0)) + sum(nvl(price_tax_charged,0)) + sum(nvl(shipping_tax_charged,0)) - sum(nvl(price_refunded,0)) - sum(nvl(shipping_refunded,0)) + sum(nvl(price_tax_refunded,0)) - sum(nvl(shipping_tax_refunded,0)),0) from ec_items where item_state <> 'void' and order_id=:order_id
      </querytext>
</fullquery>

 
<fullquery name="certificate_amount_used_select">      
      <querytext>
      select ec_order_gift_cert_amount(:order_id) from dual
      </querytext>
</fullquery>

 
<fullquery name="problems_log_insert">      
      <querytext>
      insert into ec_problems_log
      (problem_id, problem_date, problem_details, order_id)
      values
      (ec_problem_id_sequence.nextval, sysdate, 'We were unable to reinstate the customer''s gift certificate balance because the amount to be reinstated was larger than the original amount used.  This shouldn''t have happened unless there was a programming error or unless the database was incorrectly updated manually.  The voiding of this order has been aborted.', :order_id)
      
      </querytext>
</fullquery>

 
<fullquery name="reinstatable_amount_select">      
      <querytext>
      select ec_one_gift_cert_on_one_order(:cert,:order_id) from dual
      </querytext>
</fullquery>

 
<fullquery name="reinstate_gift_certificate_insert">      
      <querytext>
      insert into ec_gift_certificate_usage
	    (gift_certificate_id, order_id, amount_reinstated, reinstated_date)
	    values
	    (:cert, :order_id, :iteration_reinstate_amount, sysdate)
	    
      </querytext>
</fullquery>

 
</queryset>
