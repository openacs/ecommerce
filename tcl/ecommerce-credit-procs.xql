<?xml version="1.0"?>

<queryset>

  <fullquery name="ec_creditcard_authorization.order_data_select">      
    <querytext>
      select ec_order_cost(:order_id) as total_amount, creditcard_id
      from ec_orders
      where order_id = :order_id
    </querytext>
  </fullquery>
  
  <fullquery name="ec_creditcard_authorization.transaction_data_select">      
    <querytext>
      select transaction_amount as total_amount, creditcard_id
      from ec_financial_transactions
      where transaction_id = :transaction_id
    </querytext>
  </fullquery>

  <fullquery name="ec_creditcard_authorization.creditcard_data_select">      
    <querytext>
      select c.creditcard_number as card_number, substring(creditcard_expire for 2) as card_exp_month, substring(creditcard_expire from 4 for 2) as card_exp_year, 
	  c.creditcard_type, p.first_names || ' ' || p.last_name as card_name,
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
  
  <fullquery name="ec_creditcard_authorization.update_transaction_id">
    <querytext>
      update ec_financial_transactions 
      set transaction_id = :pgw_transaction_id
      where transaction_id = :transaction_id
    </querytext>
  </fullquery>

  <fullquery name="ec_creditcard_marking.transaction_select">      
    <querytext>
      select f.transaction_amount, f.transaction_id, c.creditcard_type, p.first_names || ' ' || p.last_name as card_name, 
	  c.creditcard_number as card_number, substring(creditcard_expire for 2) as card_exp_month, substring(creditcard_expire from 4 for 2) as card_exp_year, c.creditcard_type, 
          a.zip_code as billing_zip,
          a.line1 as billing_address, 
          a.city as billing_city, 
          coalesce(a.usps_abbrev, a.full_state_name) as billing_state, 
          a.country_code as billing_country
      from ec_financial_transactions f, ec_creditcards c, persons p, ec_addresses a  
      where transaction_id = :transaction_id
      and f.creditcard_id = c.creditcard_id 
      and c.user_id = p.person_id
      and c.billing_address = a.address_id
    </querytext>
  </fullquery>

  <fullquery name="ec_creditcard_marking.update_transaction_id">
    <querytext>
      update ec_financial_transactions 
      set transaction_id = :pgw_transaction_id
      where transaction_id = :transaction_id
    </querytext>
  </fullquery>

  <fullquery name="ec_creditcard_return.transaction_info_select">      
    <querytext>
      select t.refunded_transaction_id, t.transaction_amount, 
          c.creditcard_number as card_number, substring(creditcard_expire for 2) as card_exp_month, substring(creditcard_expire from 4 for 2) as card_exp_year, c.creditcard_type,
          p.first_names || ' ' || p.last_name as card_name, 
          a.zip_code as billing_zip,
          a.line1 as billing_address, 
          a.city as billing_city, 
          coalesce(a.usps_abbrev, a.full_state_name) as billing_state, 
          a.country_code as billing_country
      from ec_financial_transactions t, ec_creditcards c, persons p, ec_addresses a  
      where t.transaction_id = :transaction_id 
      and c.creditcard_id = t.creditcard_id
      and c.user_id = p.person_id
      and c.billing_address = a.address_id
    </querytext>
  </fullquery>

  <fullquery name="ec_creditcard_return.transaction_failure_update">
    <querytext>
      update ec_financial_transactions 
      set failed_p = 't'
      where transaction_id = :transaction_id
    </querytext>
  </fullquery>
  
</queryset>
