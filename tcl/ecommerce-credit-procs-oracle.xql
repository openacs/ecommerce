<?xml version="1.0"?>

<queryset>
  <rdbms>
    <type>oracle</type>
    <version>8.1.6</version>
  </rdbms>

  <fullquery name="ec_creditcard_authorization.creditcard_data_select">      
    <querytext>
      select c.creditcard_number as card_number, substr(creditcard_expire,1,2) as card_exp_month, substr(creditcard_expire,4,2) as card_exp_year, 
	  c.creditcard_type, p.first_names || ' ' || p.last_name as card_name,
          a.zip_code as billing_zip,
          a.line1 as billing_address, 
          a.city as billing_city, 
          nvl(a.usps_abbrev, a.full_state_name) as billing_state, 
          a.country_code as billing_country
      from ec_creditcards c, persons p, ec_addresses a 
      where c.user_id=p.person_id 
      and c.creditcard_id = :creditcard_id
      and c.billing_address = a.address_id
    </querytext>
  </fullquery>

</queryset>
