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

  <fullquery name="tax_states">      
    <querytext>
      select tax_rate, initcap(state_name) as state 
      from ec_sales_tax_by_state tax, us_states state 
      where state.abbrev = tax.usps_abbrev
    </querytext>
  </fullquery>

</queryset>
