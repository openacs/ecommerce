<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="report_gc_error_into_log">      
      <querytext>
      insert into ec_problems_log
	(problem_id, problem_date, problem_details, gift_certificate_id)
	values
	(ec_problem_id_sequence.nextval, current_timestamp, 'Customer pushed reload on gift-certificate-finalize-order.tcl but gift_certificate_state wasn't authorized_plus_avs, authorized_minus_avs, failed_authorization, or confirmed',:gift_certificate_id)
	
      </querytext>
</fullquery>


<fullquery name="report_gc_error_into_log">      
      <querytext>

      insert into ec_gift_certificates
     (gift_certificate_id, gift_certificate_state, amount, issue_date, purchased_by, expires, claim_check, certificate_message, certificate_to, certificate_from, recipient_email, last_modified, last_modifying_user, modified_ip_address)
     values
     (:gift_certificate_id, 'confirmed', :amount, current_timestamp, :user_id, current_timestamp + ':gc_months months'::interval,:claim_check, :certificate_message, :certificate_to, :certificate_from, :recipient_email, current_timestamp, :user_id, :peeraddr)
	
      </querytext>
</fullquery>


<fullquery name="insert_new_gc_into_db">      
      <querytext>
      insert into ec_gift_certificates
    (gift_certificate_id, gift_certificate_state, amount, issue_date, purchased_by, expires, claim_check, certificate_message, certificate_to, certificate_from, recipient_email, last_modified, last_modifying_user, modified_ip_address)
      values
      (:gift_certificate_id, 'confirmed', :amount, current_timestamp, :user_id, current_timestamp + '$gc_months months'::interval,:claim_check, :certificate_message, :certificate_to, :certificate_from, :recipient_email, current_timestamp, :user_id, :peeraddr)
    
      </querytext>
</fullquery>


<fullquery name="insert_ec_financial_trans">      
      <querytext>
      insert into ec_financial_transactions
    (transaction_id, gift_certificate_id, creditcard_id, transaction_amount, transaction_type, inserted_date)
    values
    (:transaction_id, :gift_certificate_id, :creditcard_id, :amount, 'charge', current_timestamp)
    
      </querytext>
</fullquery>

 
<fullquery name="update_ft_set_status">      
      <querytext>
      update ec_financial_transactions set authorized_date=current_timestamp, to_be_captured_p='t' where transaction_id=:transaction_id
      </querytext>
</fullquery>

 
<fullquery name="upate_ec_gc_status">      
      <querytext>
      update ec_gift_certificates set authorized_date=current_timestamp, gift_certificate_state=:cc_result where gift_certificate_id=:gift_certificate_id
      </querytext>
</fullquery>

 
<fullquery name="get_n_seconds">      
      <querytext>
      select extract(day from (current_timestamp-issue_date))*86400 +
      extract(hour from (current_timestamp-issue_date))*3600 +
      extract(min from (current_timestamp-issue_date))*60 +
      extract(sec from (current_timestamp-issue_date)) as n_seconds from ec_gift_certificates where gift_certificate_id = :gift_certificate_id
      </querytext>
</fullquery>

 
</queryset>
