<?xml version="1.0"?>

<queryset>

  <fullquery name="ec_calculate_product_purchase_combinations.products_select">      
    <querytext>
      select product_id from ec_products where active_p = 't'
    </querytext>
  </fullquery>
  
  <fullquery name="ec_calculate_product_purchase_combinations.correlated_products_select">      
    <querytext>
      select i2.product_id as correlated_product_id,
      count(*) as n_product_occurrences
      from ec_items i2, ec_products p
      where i2.order_id in (select o2.order_id
          from ec_orders o2
          where o2.user_id in (select user_id
              from ec_orders o
              where o.order_id in (select i.order_id
                  from ec_items i
                  where product_id = :product_id)))
      and i2.product_id = p.product_id
      and p.active_p = 't'
      and i2.product_id <> :product_id
      group by i2.product_id
      order by n_product_occurrences desc
    </querytext>
  </fullquery>
  
  <fullquery name="ec_calculate_product_purchase_combinations.product_purchase_comb_select">      
    <querytext>
      select count(*) 
      from ec_product_purchase_comb 
      where product_id = :product_id
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
      where product_id = :product_id
    </querytext>
  </fullquery>
  
  <fullquery name="ec_sweep_for_payment_zombies.order_failure_update">      
    <querytext>
      update ec_orders 
      set order_state = 'failed_authorization'
      where order_id = :order_id
    </querytext>
  </fullquery>
  
  <fullquery name="ec_sweep_for_payment_zombies.transaction_failure_update">      
    <querytext>
      update ec_financial_transactions 
      set failed_p = 't'
      where transaction_id = :transaction_id
    </querytext>
  </fullquery>
  
  <fullquery name="ec_sweep_for_payment_zombie_gift_certificates.transaction_failure_update">      
    <querytext>
      update ec_financial_transactions 
      set failed_p = 't', to_be_captured_p = 'f' 
      where transaction_id = :transaction_id
    </querytext>
  </fullquery>
  
  <fullquery name="ec_sweep_for_payment_zombie_gift_certificates.certificate_failure_update">      
    <querytext>
      update ec_gift_certificates 
      set gift_certificate_state = 'failed_authorization' 
      where gift_certificate_id = :gift_certificate_id
    </querytext>
  </fullquery>
  
  <fullquery name="ec_send_unsent_new_order_email.orders_select">      
    <querytext>
      select order_id
      from ec_orders o
      where order_state = 'authorized'
      and (0 = (select count(*) 
         from ec_automatic_email_log log 
         where log.order_id = o.order_id and email_template_id = 1))
    </querytext>
  </fullquery>
  
  <fullquery name="ec_send_unsent_new_gift_certificate_order_email.certificates_select">      
    <querytext>
      select gift_certificate_id
      from ec_gift_certificates g
      where gift_certificate_state = 'authorized' 
      and (0 = (select count(*) 
          from ec_automatic_email_log log 
          where log.gift_certificate_id = g.gift_certificate_id 
          and email_template_id = 4))
    </querytext>
  </fullquery>
  
  <fullquery name="ec_send_unsent_gift_certificate_recipient_email.certificates_select">      
    <querytext>
      select gift_certificate_id
      from ec_gift_certificates g
      where gift_certificate_state = 'authorized' 
      and (0 = (select count(*) 
          from ec_automatic_email_log log 
          where log.gift_certificate_id = g.gift_certificate_id 
          and email_template_id = 5))
    </querytext>
  </fullquery>
  
  <fullquery name="ec_delayed_credit_denied.orders_select">      
    <querytext>
      select order_id 
      from ec_orders 
      where order_state = 'failed_authorization'
    </querytext>
  </fullquery>
  
  <fullquery name="ec_delayed_credit_denied.order_state_update">      
    <querytext>
      update ec_orders 
      set order_state = 'in_basket', saved_p = 't' 
      where order_id = :order_id
    </querytext>
  </fullquery>

  <fullquery name="ec_unauthorized_transactions.transaction_failed_update">      
    <querytext>
      update ec_financial_transactions 
      set failed_p = 't' 
      where transaction_id = :transaction_id
    </querytext>
  </fullquery>
  
  <fullquery name="ec_unmarked_transactions.transactions_select">      
    <querytext>
      select f.transaction_id, f.order_id, f.transaction_amount, f.to_be_captured_date, 
          p.first_names || ' ' || p.last_name as card_name, 
	  c.creditcard_number as card_number, substring(creditcard_expire for 2) as card_exp_month, substring(creditcard_expire from 4 for 2) as card_exp_year, c.creditcard_type, 
          a.zip_code as billing_zip,
	  a.line1 as billing_address, 
	  a.city as billing_city, 
          coalesce(a.usps_abbrev, a.full_state_name) as billing_state, 
          a.country_code as billing_country
      from ec_financial_transactions f, ec_creditcards c, persons p, ec_addresses a
      where to_be_captured_p = 't'
      and marked_date is null
      and f.failed_p = 'f'
      and f.creditcard_id = c.creditcard_id 
      and c.user_id = p.person_id
      and c.billing_address = a.address_id
    </querytext>
  </fullquery>
  
  <fullquery name="ec_unmarked_transactions.transaction_failed_update">      
    <querytext>
      update ec_financial_transactions 
      set failed_p = 't' 
      where transaction_id = :transaction_id
    </querytext>
  </fullquery>
  
</queryset>
