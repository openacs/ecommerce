<?xml version="1.0"?>

<queryset>

  <fullquery name="get_gift_c_id">      
    <querytext>
      select count(*) 
      from ec_gift_certificates 
      where gift_certificate_id=:gift_certificate_id
    </querytext>
  </fullquery>

  <fullquery name="get_gift_c_status">      
    <querytext>
      select gift_certificate_state 
      from ec_gift_certificates 
      where gift_certificate_id=:gift_certificate_id
    </querytext>
  </fullquery>

  <fullquery name="get_ec_credit_card">      
    <querytext>
      insert into ec_creditcards
      (creditcard_id, user_id, creditcard_number, creditcard_last_four, creditcard_type, creditcard_expire, billing_address)
      values
      (:creditcard_id, :user_id, :creditcard_number, :ccstuff_1, :creditcard_type, :expiry, :address_id)
    </querytext>
  </fullquery>

  <fullquery name="creditcard_data_select">
    <querytext>
      select c.creditcard_number as card_number, substring(creditcard_expire for 2) as card_exp_month, substring(creditcard_expire from 4 for 2) as card_exp_year, c.creditcard_type,
      p.first_names || ' ' || p.last_name as card_name, 
      a.zip_code as billing_zip,
      a.line1 as billing_address, 
      a.city as billing_city, 
      coalesce(a.usps_abbrev, a.full_state_name) as billing_state, 
      a.country_code as billing_country
      from ec_creditcards c, persons p, ec_addresses a
      where c.user_id=p.person_id 
      and c.creditcard_id = :creditcard_id
      and c.billing_address = a.address_id
    </querytext>
  </fullquery>

  <fullquery name="set_ft_failure">      
    <querytext>
      update ec_financial_transactions 
      set failed_p='t', to_be_captured_p='f'
      where transaction_id=:transaction_id
    </querytext>
  </fullquery>

  <fullquery name="set_gc_failure">      
    <querytext>
      update ec_gift_certificates 
      set gift_certificate_state='failed_authorization' 
      where gift_certificate_id=:gift_certificate_id
    </querytext>
  </fullquery>

</queryset>
