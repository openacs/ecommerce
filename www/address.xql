<?xml version="1.0"?>

<queryset>

  <fullquery name="get_full_name">      
    <querytext>
      select first_names || ' ' || last_name as name 
      from cc_users
      where user_id=:user_id
    </querytext>
  </fullquery>

  <fullquery name="select_address">      
    <querytext>
      select attn, line1, line2, city, usps_abbrev, zip_code, phone, country_code, full_state_name, phone_time 
      from ec_addresses
      where address_id=:address_id
    </querytext>
  </fullquery>

</queryset>
