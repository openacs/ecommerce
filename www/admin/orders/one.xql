<?xml version="1.0"?>
<queryset>
 
  <fullquery name="voided_by_name_select">      
    <querytext>
      select first_names || ' ' || last_name 
      from cc_users
      where user_id=:voided_by
    </querytext>
  </fullquery>
  
  <fullquery name="products_select">      
    <querytext>
      select p.product_name, p.product_id, i.price_name, i.price_charged, count(*) as quantity, i.item_state, i.color_choice, i.size_choice, i.style_choice
      from ec_items i, ec_products p
      where i.product_id=p.product_id
      and i.order_id=:order_id
      group by p.product_name, p.product_id, i.price_name, i.price_charged, i.item_state, i.color_choice, i.size_choice, i.style_choice
    </querytext>
  </fullquery>
  
  <fullquery name="financial_transactions_select">      
    <querytext>
      select t.transaction_id, t.inserted_date, t.transaction_amount, t.transaction_type, t.to_be_captured_p, 
          t.authorized_date, t.marked_date, t.refunded_date, t.failed_p, c.creditcard_last_four
      from ec_financial_transactions t, ec_creditcards c
      where t.creditcard_id=c.creditcard_id
      and t.order_id=:order_id
      order by transaction_id
    </querytext>
  </fullquery>
  
  <fullquery name="shipments_items_products_select">      
    <querytext>
      select s.shipment_id, s.address_id, s.shipment_date, s.expected_arrival_date, s.carrier, s.tracking_number, 
          s.actual_arrival_date, s.actual_arrival_detail, p.product_name, p.product_id, i.price_name, i.price_charged, count(*) as quantity
      from ec_shipments s, ec_items i, ec_products p
      where i.shipment_id=s.shipment_id
      and i.product_id=p.product_id
      and s.order_id=:order_id
      group by s.shipment_id, s.address_id, s.shipment_date, s.expected_arrival_date, s.carrier, s.tracking_number, 
          s.actual_arrival_date, s.actual_arrival_detail, p.product_name, p.product_id, i.price_name, i.price_charged
      order by s.shipment_id
    </querytext>
  </fullquery>
  
  <fullquery name="refunds_select">      
    <querytext>
      select r.refund_id, r.refund_date, r.refunded_by, r.refund_reasons, r.refund_amount, u.first_names, u.last_name,
          p.product_name, p.product_id, i.price_name, i.price_charged, count(*) as quantity
      from ec_refunds r, cc_users u, ec_items i, ec_products p
      where r.order_id=:order_id
      and r.refunded_by=u.user_id
      and i.refund_id=r.refund_id
      and p.product_id=i.product_id
      group by r.refund_id, r.refund_date, r.refunded_by, r.refund_reasons, r.refund_amount, u.first_names, u.last_name, 
          p.product_name, p.product_id, i.price_name, i.price_charged
    </querytext>
  </fullquery>
  
</queryset>
