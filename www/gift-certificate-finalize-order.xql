<?xml version="1.0"?>
<queryset>

<fullquery name="get_gift_c_id">      
      <querytext>
      select count(*) from ec_gift_certificates where gift_certificate_id=:gift_certificate_id
      </querytext>
</fullquery>

 
<fullquery name="get_gift_c_status">      
      <querytext>
      select gift_certificate_state from ec_gift_certificates where gift_certificate_id=:gift_certificate_id
      </querytext>
</fullquery>

 
<fullquery name="get_ec_credit_card">      
      <querytext>
      insert into ec_creditcards
    (creditcard_id, user_id, creditcard_number, creditcard_last_four, creditcard_type, creditcard_expire, billing_zip_code)
    values
    (:creditcard_id, :user_id, :creditcard_number, :ccstuff_1, :creditcard_type,:expiry,:billing_zip_code)
    
      </querytext>
</fullquery>

 
<fullquery name="set_ft_failure">      
      <querytext>
      update ec_financial_transactions set failed_p='t', to_be_captured_p='f' where transaction_id=:transaction_id
      </querytext>
</fullquery>

 
<fullquery name="set_gc_failure">      
      <querytext>
      update ec_gift_certificates set gift_certificate_state='failed_authorization' where gift_certificate_id=:gift_certificate_id
      </querytext>
</fullquery>

 
</queryset>
