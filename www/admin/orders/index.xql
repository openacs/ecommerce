<?xml version="1.0"?>
<queryset>

  <fullquery name="recent_orders_select">      
    <querytext>
      select 
      	sum(one_if_within_n_days(confirmed_date,1)) as n_o_in_last_24_hours,
      	sum(one_if_within_n_days(confirmed_date,7)) as n_o_in_last_7_days
      from ec_orders_reportable
    </querytext>
  </fullquery>

  <fullquery name="recent_gift_certificates_purchased_select">      
    <querytext>
      select
      	sum(one_if_within_n_days(issue_date,1)) as n_g_in_last_24_hours,
      	sum(one_if_within_n_days(issue_date,7)) as n_g_in_last_7_days
      from ec_gift_certificates_purchased
    </querytext>
  </fullquery>

  <fullquery name="recent_gift_certificates_issued_select">      
    <querytext>
      select
      	sum(one_if_within_n_days(issue_date,1)) as n_gi_in_last_24_hours,
      	sum(one_if_within_n_days(issue_date,7)) as n_gi_in_last_7_days
      from ec_gift_certificates_issued
    </querytext>
  </fullquery>

  <fullquery name="recent_shipments_select">      
    <querytext>
      select
      	sum(one_if_within_n_days(shipment_date,1)) as n_s_in_last_24_hours,
      	sum(one_if_within_n_days(shipment_date,7)) as n_s_in_last_7_days
      from ec_shipments
    </querytext>
  </fullquery>
  
  <fullquery name="recent_refunds_select">      
    <querytext>
      select
      	sum(one_if_within_n_days(refund_date,1)) as n_r_in_last_24_hours,
      	sum(one_if_within_n_days(refund_date,7)) as n_r_in_last_7_days
      from ec_refunds
    </querytext>
  </fullquery>
  
  <fullquery name="standard_shipping">      
    <querytext>
      select count(*) 
      from ec_orders_shippable 
      where shipping_method='standard'
    </querytext>
  </fullquery>

  <fullquery name="express_shipping">      
    <querytext>
      select count(*) 
      from ec_orders_shippable 
      where shipping_method='express'
    </querytext>
  </fullquery>
  
</queryset>
