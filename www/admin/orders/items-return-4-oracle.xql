<?xml version="1.0"?>

<queryset>
  <rdbms>
    <type>oracle</type>
    <version>8.1.6</version>
  </rdbms>

  <fullquery name="insert_new_ec_refund">      
    <querytext>
      insert into ec_refunds
      (refund_id, order_id, refund_amount, refund_date, refunded_by, refund_reasons)
      values
      (:refund_id, :order_id, :cash_amount_to_refund, sysdate, :customer_service_rep,:reason_for_return)
    </querytext>
  </fullquery>

  <fullquery name="get_tax_charged_on_item">      
    <querytext>
      select nvl(price_tax_charged,0) as price_tax_charged, 
          nvl(shipping_tax_charged,0) as shipping_tax_charged 
      from ec_items
      where item_id=:item_id
    </querytext>
  </fullquery>

  <fullquery name="get_tax_charged">      
    <querytext>
      select ec_tax(:price_bind_variable,0,:order_id) 
      from dual
    </querytext>
  </fullquery>

  <fullquery name="get_tax_shipping_to_refund">      
    <querytext>
      select ec_tax(0,:shipping_bind_variable,:order_id) 
      from dual
    </querytext>
  </fullquery>

  <fullquery name="get_base_shipping_tax">      
    <querytext>
      select nvl(shipping_tax_charged,0)
      from ec_orders
      where order_id=:order_id
    </querytext>
  </fullquery>

  <fullquery name="get_base_tax_to_refund">      
    <querytext>
      select ec_tax(0,:base_shipping_to_refund,:order_id) 
      from dual
    </querytext>
  </fullquery>

  <fullquery name="insert_new_financial_trans">      
    <querytext>
      insert into ec_financial_transactions
      (transaction_id, order_id, refund_id, creditcard_id, transaction_amount, transaction_type, inserted_date)
      values
      (:transaction_id, :order_id, :refund_id, :creditcard_id, :cash_amount_to_refund, 'refund', sysdate)
    </querytext>
  </fullquery>

  <fullquery name="get_gc_amount_used">      
    <querytext>
      select ec_order_gift_cert_amount(:order_id) 
      from dual
    </querytext>
  </fullquery>

  <fullquery name="record_reinstate_problem">      
    <querytext>
      insert into ec_problems_log
      (problem_id, problem_date, problem_details, order_id)
      values
      (ec_problem_id_sequence.nextval, sysdate, :errorstring, :order_id)
    </querytext>
  </fullquery>

  <fullquery name="reinstateable_gift_certificates">      
    <querytext>
      select u.gift_certificate_id, nvl(sum(u.amount_used),0) - nvl(sum(u.amount_reinstated),0) as reinstateable_amount
      from ec_gift_certificate_usage u, ec_gift_certificates c
      where u.gift_certificate_id = c.gift_certificate_id
      and u.order_id = :order_id
      group by u.gift_certificate_id, c.expires
      order by expires desc, gift_certificate_id desc
    </querytext>
  </fullquery>

  <fullquery name="reinstate_gift_certificate">      
    <querytext>
      insert into ec_gift_certificate_usage
      (gift_certificate_id, order_id, amount_reinstated, reinstated_date)
      values
      (:gift_certificate_id, :order_id, least(to_number(:certificate_amount_to_reinstate), to_number(:reinstateable_amount)), sysdate)
    </querytext>
  </fullquery>

  <fullquery name="insert_cc_refund_problem">      
    <querytext>
      insert into ec_problems_log
      (problem_id, problem_date, problem_details, order_id)
      values
      (ec_problem_id_sequence.nextval, sysdate, :errorstring, :order_id)
    </querytext>
  </fullquery>

  <fullquery name="update_ft_set_success">      
    <querytext>
      update ec_financial_transactions 
      set refunded_date=sysdate 
      where transaction_id=:pgw_transaction_id
    </querytext>
  </fullquery>

  <fullquery name="reschedule_refund">      
    <querytext>
      update ec_financial_transactions
      set to_be_captured_date = sysdate
      where transaction_id = :transaction_id
    </querytext>
  </fullquery>

  <fullquery name="select_matching_charge_transaction">      
    <querytext>
      select * from (
      select transaction_id as charged_transaction_id, marked_date 
      from ec_financial_transactions 
      where order_id = :order_id
      and transaction_type = 'charge' 
      and (transaction_amount - :refund_amount) < 0.01 
      and (transaction_amount - :refund_amount) > 0
      and refunded_amount is null
      and marked_date is not null
      and failed_p = 'f'
      order by transaction_id)
      where rownum=1
    </querytext>
  </fullquery>

  <fullquery name="select_unrefunded_charge_transaction">      
    <querytext>
      select * from (
      select transaction_id as charged_transaction_id, (transaction_amount - nvl(refunded_amount, 0)) as unrefunded_amount, marked_date
      from ec_financial_transactions
      where order_id = :order_id
      and transaction_type = 'charge' 
      and (transaction_amount - nvl(refunded_amount, 0)) > 0.01
      and marked_date is not null
      and failed_p = 'f'
      order by (transaction_amount - nvl(refunded_amount, 0)) desc
      )
      where rownum=1
    </querytext>
  </fullquery>

  <fullquery name="record_refunded_amount">      
    <querytext>
      update ec_financial_transactions
      set refunded_amount = nvl(refunded_amount, 0) + :refund_amount
      where transaction_id = :charged_transaction_id
    </querytext>
  </fullquery>

  <fullquery name="record_unrefunded_amount">      
    <querytext>
      update ec_financial_transactions
      set refunded_amount = coalesce(refunded_amount, 0) + :unrefunded_amount
      where transaction_id = :charged_transaction_id
    </querytext>
  </fullquery>

  <fullquery name="insert_refund_transaction">      
    <querytext>
      insert into ec_financial_transactions
      (transaction_id, refunded_transaction_id, order_id, refund_id, creditcard_id, transaction_amount, transaction_type, inserted_date, to_be_captured_date)
      values
      (:refund_transaction_id, :charged_transaction_id, :order_id, :refund_id, :creditcard_id, :refund_amount, 'refund', sysdate, to_date(:scheduled_hour,'YYYY-MM-DD HH12:MI:SSAM'))
    </querytext>
  </fullquery>

  <fullquery name="insert_unrefund_transaction">      
    <querytext>
      insert into ec_financial_transactions
      (transaction_id, refunded_transaction_id, order_id, refund_id, creditcard_id, transaction_amount, transaction_type, inserted_date, to_be_captured_date)
      values
      (:refund_transaction_id, :charged_transaction_id, :order_id, :refund_id, :creditcard_id, :unrefunded_amount, 'refund', sysdate, to_date(:scheduled_hour,'YYYY-MM-DD HH12:MI:SSAM'))
    </querytext>
  </fullquery>

</queryset>
