<?xml version="1.0"?>
<queryset>

<fullquery name="get_sales_taxes">      
      <querytext>
      select state_name, tax_rate*100 as tax_rate_in_percent, case when shipping_p = 't' then 'Yes' else 'No' end as shipping_p
from ec_sales_tax_by_state, states
where ec_sales_tax_by_state.usps_abbrev = states.usps_abbrev
      </querytext>
</fullquery>

 
<fullquery name="get_abbrevs">      
      <querytext>
      select usps_abbrev from ec_sales_tax_by_state
      </querytext>
</fullquery>

 
</queryset>
