<?xml version="1.0"?>
<queryset>

  <fullquery name="select_billing_address">      
    <querytext>
      select c.billing_address, a.country_code
      from ec_creditcards c, ec_orders o, ec_addresses a
      where o.creditcard_id = c.creditcard_id
      and a.address_id = c.billing_address
      and o.order_id = :order_id
      limit 1
    </querytext>
  </fullquery>
  
</queryset>
