<?xml version="1.0"?>
<queryset>

<fullquery name="get_tax_rate">      
      <querytext>
      select tax_rate*100 from ec_sales_tax_by_state where usps_abbrev=:usps_abbrev
      </querytext>
</fullquery>

 
<fullquery name="get_shipping_ps">      
      <querytext>
      select shipping_p from ec_sales_tax_by_state where usps_abbrev=:usps_abbrev
      </querytext>
</fullquery>

 
</queryset>
