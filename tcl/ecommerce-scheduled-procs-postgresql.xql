<?xml version="1.0"?>

<queryset>
  <rdbms>
    <type>postgresql</type>
    <version>7.1</version>
  </rdbms>

  <fullquery name="ec_sweep_for_payment_zombies.transactions_select">      
    <querytext>
      select o.order_id, ec_order_cost(o.order_id) as total_order_price, 
	  f.transaction_id, f.inserted_date, f.transaction_amount, 
	  c.creditcard_type as card_type, a.attn as card_name, 
	  c.creditcard_number as card_number, substring(creditcard_expire for 2) as card_exp_month, substring(creditcard_expire from 4 for 2) as card_exp_year, c.creditcard_type,
          a.zip_code as billing_zip,
          a.line1 as billing_address, 
	  a.city as billing_city, 
          coalesce(a.usps_abbrev, a.full_state_name) as billing_state, 
          a.country_code as billing_country
      from ec_orders o, ec_financial_transactions f, ec_creditcards c, persons p , ec_addresses a
      where order_state = 'confirmed' 
      and (current_timestamp - confirmed_date) > timespan_days(1/96::float)
      and f.failed_p = 'f'
      and f.order_id = o.order_id
      and f.creditcard_id = c.creditcard_id 
      and c.user_id = p.person_id
      and c.billing_address = a.address_id
    </querytext>
  </fullquery>
  
  <fullquery name="ec_sweep_for_payment_zombies.problems_log_insert">      
    <querytext>
      insert into ec_problems_log
      (problem_id, problem_date, problem_details, order_id)
      values
      (ec_problem_id_sequence.nextval, current_timestamp, :problem_details, :order_id)
    </querytext>
  </fullquery>

  <fullquery name="ec_sweep_for_payment_zombie_gift_certificates.transactions_select">      
    <querytext>
      select g.gift_certificate_id, f.transaction_id, f.transaction_amount, f.inserted_date,
	  c.creditcard_type, c.creditcard_number as card_number, substring(creditcard_expire for 2) as card_exp_month, substring(creditcard_expire from 4 for 2) as card_exp_year,
          a.attn as card_name, 
          a.zip_code as billing_zip,
          a.line1 as billing_address, 
	  a.city as billing_city, 
          coalesce(a.usps_abbrev, a.full_state_name) as billing_state, 
          a.country_code as billing_country
      from ec_gift_certificates g, ec_financial_transactions f, ec_creditcards c, persons p, ec_addresses a
      where g.gift_certificate_state = 'confirmed' 
      and (current_timestamp - g.issue_date) > timespan_days(1/96::float)
      and f.failed_p = 'f'
      and g.gift_certificate_id = f.gift_certificate_id
      and f.creditcard_id = c.creditcard_id 
      and c.user_id = p.person_id 
      and c.billing_address = a.address_id
    </querytext>
  </fullquery>
  
  <fullquery name="ec_sweep_for_payment_zombie_gift_certificates.transaction_success_update">      
    <querytext>
      update ec_financial_transactions
      set transaction_id = :pgw_transaction_id, authorized_date=current_timestamp, to_be_captured_p='t'
      where transaction_id = :transaction_id
    </querytext>
  </fullquery>
  
  <fullquery name="ec_sweep_for_payment_zombie_gift_certificates.certificate_success_update">      
    <querytext>
      update ec_gift_certificates
      set authorized_date = current_timestamp, gift_certificate_state = 'authorized'
      where gift_certificate_id = :gift_certificate_id
    </querytext>
  </fullquery>
  
  <fullquery name="ec_sweep_for_payment_zombie_gift_certificates.problems_log_insert">      
    <querytext>
      insert into ec_problems_log
      (problem_id, problem_date, problem_details, order_id)
      values
      (ec_problem_id_sequence.nextval, current_timestamp, :problem_details, :order_id)
    </querytext>
  </fullquery>

  <fullquery name="ec_expire_old_carts.expired_carts_update">      
    <querytext>
      update ec_orders 
      set order_state='expired', expired_date=current_timestamp 
      where order_state='in_basket' 
      and current_timestamp-in_basket_date > timespan_days(:cart_duration::float)
    </querytext>
  </fullquery>
  
  <fullquery name="ec_expire_old_carts.item_state_update">      
    <querytext>
      update ec_items 
      set item_state='expired', expired_date=current_timestamp 
      where item_state='in_basket' and order_id in (select order_id 
          from ec_orders 
          where order_state='expired')
    </querytext>
  </fullquery>
  
  <fullquery name="ec_remove_creditcard_data.creditcard_update">      
    <querytext>
      update ec_creditcards
      set creditcard_number=null
      where creditcard_id in (select distinct c.creditcard_id
          from ec_creditcards c, ec_orders o
          where c.creditcard_id = o.creditcard_id
          and c.creditcard_number is not null
          and 0=(select count(*)
             from ec_orders o2
             where o2.creditcard_id=c.creditcard_id
             and o2.order_state not in ('fulfilled','returned','void','expired'))
      	  and 0=(select count(*)
	     from ec_financial_transactions f
	     where f.transaction_type = 'refund'
             and f.creditcard_id = c.creditcard_id
	     and refunded_date is null))
    </querytext>
  </fullquery>
  
  <fullquery name="ec_unauthorized_transactions.transactions_select">      
    <querytext>
      select f.transaction_id, f.order_id, f.transaction_amount, f.to_be_captured_date, 
          a.attn as card_name, 
          substring(creditcard_expire for 2) as card_exp_month, substring(creditcard_expire from 4 for 2) as card_exp_year, c.creditcard_number as card_number, c.creditcard_type,
          a.zip_code as billing_zip,
          a.line1 as billing_address, 
	  a.city as billing_city, 
          coalesce(a.usps_abbrev, a.full_state_name) as billing_state, 
          a.country_code as billing_country
      from ec_financial_transactions f, ec_creditcards c, persons p, ec_addresses a
      where to_be_captured_p='t'
      and current_timestamp-to_be_captured_date > timespan_days(1/48::float)
      and authorized_date is null
      and f.failed_p='f'
      and f.creditcard_id=c.creditcard_id 
      and c.user_id=p.person_id
      and c.billing_address = a.address_id
    </querytext>
  </fullquery>
  
  <fullquery name="ec_unauthorized_transactions.problems_log_insert">      
    <querytext>
      insert into ec_problems_log
      (problem_id, problem_date, problem_details, order_id)
      values
      (ec_problem_id_sequence.nextval, current_timestamp, :problem_details, :order_id)
    </querytext>
  </fullquery>

  <fullquery name="ec_unauthorized_transactions.transaction_success_update">      
    <querytext>
      update ec_financial_transactions 
      set transaction_id = :pgw_transaction_id, authorized_date=current_timestamp 
      where transaction_id=:transaction_id
    </querytext>
  </fullquery>

  <fullquery name="ec_unmarked_transactions.problems_log_insert">      
    <querytext>
      insert into ec_problems_log
      (problem_id, problem_date, problem_details, order_id)
      values
      (ec_problem_id_sequence.nextval, current_timestamp, :problem_details, :order_id)
    </querytext>
  </fullquery>
  
  <fullquery name="ec_unmarked_transactions.transaction_success_update">      
    <querytext>
      update ec_financial_transactions 
      set marked_date=current_timestamp, transaction_id = :pgw_transaction_id 
      where transaction_id=:transaction_id
    </querytext>
  </fullquery>

  <fullquery name="ec_unrefunded_transactions.transactions_select">      
    <querytext>
      select f.transaction_id, f.order_id, f.transaction_amount, f.to_be_captured_date, 
          a.attn as card_name, 
	  c.creditcard_number as card_number, c.creditcard_type, substring(creditcard_expire for 2) as card_exp_month, substring(creditcard_expire from 4 for 2) as card_exp_year,
          a.zip_code as billing_zip,
	  a.line1 as billing_address, 
	  a.city as billing_city, 
          coalesce(a.usps_abbrev, a.full_state_name) as billing_state, 
          a.country_code as billing_country, f.refunded_transaction_id
      from ec_financial_transactions f, ec_creditcards c, persons p, ec_addresses a 
      where transaction_type = 'refund'
      and f.refunded_date is null
      and f.failed_p='f'
      and f.creditcard_id = c.creditcard_id 
      and c.user_id = p.person_id
      and c.billing_address = a.address_id
      and current_timestamp-to_be_captured_date > timespan_days(1/48::float)
    </querytext>
  </fullquery>
  
  <fullquery name="ec_unrefunded_transactions.problems_log_insert">
    <querytext>
      insert into ec_problems_log
      (problem_id, problem_date, problem_details, order_id)
      values
      (ec_problem_id_sequence.nextval, current_timestamp, :problem_details, :order_id)
    </querytext>
  </fullquery>
  
  <fullquery name="ec_unrefunded_transactions.transaction_success_update">      
    <querytext>
      update ec_financial_transactions 
      set transaction_id = :pgw_transaction_id, refunded_date=current_timestamp 
      where transaction_id=:transaction_id
    </querytext>
  </fullquery>
  
</queryset>
