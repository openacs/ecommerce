<?xml version="1.0"?>

<queryset>
  <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

  <fullquery name="reportable_transactions_select">      
    <querytext>
      select to_char(inserted_date,'YYYY') as transaction_year, to_char(inserted_date,'Q') as transaction_quarter, 
          sum(case when transaction_type = 'charge' then transaction_amount else -1*transaction_amount end) as revenue
      from ec_fin_transactions_reportable
      group by to_char(inserted_date,'YYYY'), to_char(inserted_date,'Q')
      order by to_char(inserted_date,'YYYY') || to_char(inserted_date,'Q')
    </querytext>
  </fullquery>
  
  <fullquery name="money_select">      
    <querytext>
     select to_char(shipment_date,'YYYY') as shipment_year,
      to_char(shipment_date,'Q') as shipment_quarter,
      nvl(sum(bal_price_charged),0) as total_price_charged,
      nvl(sum(bal_shipping_charged + decode(mv.shipment_id,(
          select min(s2.shipment_id) 
          from ec_shipments s2 
          where s2.order_id=mv.order_id),
          (select nvl(o.shipping_charged,0)-nvl(o.shipping_refunded,0) from
           ec_orders o where o.order_id=mv.order_id),0)),0)  as total_shipping_charged,
      nvl(sum(bal_tax_charged + decode(mv.shipment_id,(
           select min(s2.shipment_id) 
           from ec_shipments s2 where s2.order_id=mv.order_id),(
               select nvl(o.shipping_tax_charged,0)-nvl(o.shipping_tax_refunded,0) from
               ec_orders o where o.order_id=mv.order_id),0)),0) as total_tax_charged
      from ec_items_money_view mv
      group by to_char(shipment_date,'YYYY'), to_char(shipment_date,'Q')
      order by to_char(shipment_date,'YYYY') || to_char(shipment_date,'Q')
    </querytext>
  </fullquery>
  
  <fullquery name="gift_certificates_select">      
    <querytext>
      select to_char(issue_date,'YYYY') as issue_year,
      to_char(issue_date,'Q') as issue_quarter,
      nvl(sum(amount),0) as amount
      from ec_gift_certificates where gift_certificate_state = 'authorized'
      group by to_char(issue_date,'YYYY'), to_char(issue_date,'Q')
      order by to_char(issue_date,'YYYY') || to_char(issue_date,'Q')
    </querytext>
  </fullquery>
  
  <fullquery name="gift_certificates_select">      
    <querytext>
      select to_char(issue_date,'YYYY') as issue_year,
      to_char(issue_date,'Q') as issue_quarter,
      nvl(sum(amount),0) as amount
      from ec_gift_certificates where gift_certificate_state = 'authorized'
      group by to_char(issue_date,'YYYY'), to_char(issue_date,'Q')
      order by to_char(issue_date,'YYYY') || to_char(issue_date,'Q')
    </querytext>
  </fullquery>
  
  <fullquery name="gift_certificates_approved_select">      
    <querytext>
      select to_char(expires,'YYYY') as expires_year,
      to_char(expires,'Q') as expires_quarter,
      nvl(sum(gift_certificate_amount_left(gift_certificate_id)),0) + nvl(sum(ec_gift_cert_unshipped_amount(gift_certificate_id)),0) as amount_outstanding
      from ec_gift_certificates_approved
      group by to_char(expires,'YYYY'), to_char(expires,'Q')
      order by to_char(expires,'YYYY') || to_char(expires,'Q')
    </querytext>
  </fullquery>

</queryset>
