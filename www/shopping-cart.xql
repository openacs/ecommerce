<?xml version="1.0"?>

<queryset>

  <fullquery name="get_n_items">      
    <querytext>
      select count(*) 
      from ec_orders o, ec_items i
      where o.order_id=i.order_id
      and o.user_session_id=:user_session_id and o.order_state='in_basket'
    </querytext>
  </fullquery>


  <fullquery name="get_shipping_address_ids">
    <querytext>
      select address_id
      from ec_addresses
      where user_id=:user_id
      and address_type = 'shipping'
    </querytext>
  </fullquery>

  <fullquery name="select_shipping_area">
    <querytext>
      select country_code, zip_code 
      from ec_addresses
      where address_id = :shipping_address_id
    </querytext>
  </fullquery>

  <fullquery name="tax_states">      
    <querytext>
      select tax_rate, initcap(state_name) as state 
      from ec_sales_tax_by_state tax, us_states state 
      where state.abbrev = tax.usps_abbrev
    </querytext>
  </fullquery>

</queryset>
