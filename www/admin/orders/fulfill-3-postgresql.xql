<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="total_tax_of_items_select">      
      <querytext>
      select ec_tax(:total_price_of_items, :total_shipping_of_items, :order_id) 
      </querytext>
</fullquery>

 
<fullquery name="insert_shipment_info">      
      <querytext>
      insert into ec_shipments
  (shipment_id, order_id, shipment_date, expected_arrival_date, carrier, tracking_number, shippable_p, last_modified, last_modifying_user, modified_ip_address)
  values
  (:shipment_id, :order_id, to_date(:shipment_date, 'YYYY-MM-DD HH12:MI:SSAM'), to_date(:expected_arrival_date, 'YYYY-MM-DD HH12:MI:SSAM'), :carrier, :tracking_number, :shippable_p_tf, current_timestamp, :customer_service_rep, :peeraddr)
  
      </querytext>
</fullquery>

 
<fullquery name="shipment_cost_select">      
      <querytext>
      select ec_shipment_cost(:shipment_id) 
      </querytext>
</fullquery>

 
<fullquery name="order_cost_select">      
      <querytext>
      select ec_order_cost(:order_id) 
      </querytext>
</fullquery>

 
<fullquery name="transaction_update">      
      <querytext>
      update ec_financial_transactions set shipment_id=:shipment_id, to_be_captured_p='t', to_be_captured_date=current_timestamp where transaction_id=:transaction_id
      </querytext>
</fullquery>

 
<fullquery name="problems_log_insert">      
      <querytext>
      insert into ec_problems_log
	(problem_id, problem_date, problem_details, order_id)
	values
	(ec_problem_id_sequence.nextval, current_timestamp, :problem_details, :order_id)
	
      </querytext>
</fullquery>

 
<fullquery name="transaction_success_update">      
      <querytext>
      update ec_financial_transactions set marked_date=current_timestamp where transaction_id=:transaction_id
      </querytext>
</fullquery>

 
<fullquery name="transaction_id_insert">      
      <querytext>
      insert into ec_financial_transactions
      (transaction_id, order_id, shipment_id, transaction_amount, transaction_type, to_be_captured_p, inserted_date, to_be_captured_date)
      values
      (:transaction_id, :order_id, :shipment_id, :shipment_cost, 'charge','t',current_timestamp,current_timestamp)
      
      </querytext>
</fullquery>

 
<fullquery name="problems_insert">      
      <querytext>
      
	insert into ec_problems_log
	(problem_id, problem_date, problem_details, order_id)
	values
	(ec_problem_id_sequence.nextval, current_timestamp, :problem_details, :order_id)
	
      </querytext>
</fullquery>

 
<fullquery name="transaction_authorized_udpate">      
      <querytext>
      update ec_financial_transactions set authorized_date=current_timestamp where transaction_id=:transaction_id
      </querytext>
</fullquery>

 
<fullquery name="problems_insert">      
      <querytext>
      insert into ec_problems_log
	  (problem_id, problem_date, problem_details, order_id)
	  values
	  (ec_problem_id_sequence.nextval, current_timestamp, :problem_details, :order_id)
	  
      </querytext>
</fullquery>

 
<fullquery name="transaction_success_update">      
      <querytext>
      update ec_financial_transactions set marked_date=current_timestamp where transaction_id=:transaction_id
      </querytext>
</fullquery>

 
</queryset>
