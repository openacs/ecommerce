<?xml version="1.0"?>
<queryset>

  <fullquery name="get_count_refunds">      
    <querytext>
      select count(*) 
      from ec_refunds 
      where refund_id=:refund_id
    </querytext>
  </fullquery>

  <fullquery name="get_billing_info">      
    <querytext>
      select c.creditcard_id, c.creditcard_type, c.creditcard_number, c.creditcard_last_four, 
	  c.creditcard_expire as card_expiration, 
	  p.first_names || ' ' || p.last_name as card_name,
	  a.line1 as billing_street, a.city as billing_city, a.usps_abbrev as billing_state, a.zip_code as billing_zip, a.country_code as billing_country
      from ec_orders o, ec_creditcards c, persons p, ec_addresses a 
      where o.creditcard_id = c.creditcard_id
      and c.billing_address=a.address_id 
      and c.user_id = p.person_id
      and o.order_id=:order_id
    </querytext>
  </fullquery>
  
</queryset>
