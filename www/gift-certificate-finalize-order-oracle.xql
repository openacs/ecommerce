<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="report_gc_error_into_log">      
      <querytext>
      insert into ec_problems_log
	(problem_id, problem_date, problem_details, gift_certificate_id)
	values
	(ec_problem_id_sequence.nextval, sysdate, 'Customer pushed reload on gift-certificate-finalize-order.tcl but gift_certificate_state wasn't authorized_plus_avs, authorized_minus_avs, failed_authorization, or confirmed',:gift_certificate_id)
	
      </querytext>
</fullquery>

 
<fullquery name="get_cc_id">      
      <querytext>
      select ec_creditcard_id_sequence.nextval from dual
      </querytext>
</fullquery>

 
<fullquery name="">      
      <querytext>
      insert into ec_gift_certificates
    (gift_certificate_id, gift_certificate_state, amount, issue_date, purchased_by, expires, claim_check, certificate_message, certificate_to, certificate_from, recipient_email, last_modified, last_modifying_user, modified_ip_address)
    values
    (:gift_certificate_id, 'confirmed', :amount, sysdate, :user_id, add_months(sysdate,:gc_months),:claim_check, :certificate_message, :certificate_to, :certificate_from, :recipient_email, sysdate, :user_id, :peeraddr)
    
      </querytext>
</fullquery>

 
<fullquery name="get_transaction_id">      
      <querytext>
      select ec_transaction_id_sequence.nextval from dual
      </querytext>
</fullquery>

 
<fullquery name="insert_ec_financial_trans">      
      <querytext>
      insert into ec_financial_transactions
    (transaction_id, gift_certificate_id, creditcard_id, transaction_amount, transaction_type, inserted_date)
    values
    (:transaction_id, :gift_certificate_id, :creditcard_id, :amount, 'charge', sysdate)
    
      </querytext>
</fullquery>

 
<fullquery name="update_ft_set_status">      
      <querytext>
      update ec_financial_transactions set authorized_date=sysdate, to_be_captured_p='t' where transaction_id=:transaction_id
      </querytext>
</fullquery>

 
<fullquery name="upate_ec_gc_status">      
      <querytext>
      update ec_gift_certificates set authorized_date=sysdate, gift_certificate_state=:cc_result where gift_certificate_id=:gift_certificate_id
      </querytext>
</fullquery>

 
<fullquery name="get_cert_id_seq">      
      <querytext>
      select ec_gift_cert_id_sequence.nextval from dual
      </querytext>
</fullquery>

 
<fullquery name="get_n_seconds">      
      <querytext>
      select round((sysdate-issue_date)*86400) as n_seconds from ec_gift_certificates where gift_certificate_id = :gift_certificate_id
      </querytext>
</fullquery>

 
</queryset>
