<?xml version="1.0"?>
<queryset>

<fullquery name="clear_sales_taxes_audit">      
      <querytext>
      
        select usps_abbrev
          from ec_sales_tax_by_state
    
      </querytext>
</fullquery>

 
<fullquery name="clear_sales_taxes">      
      <querytext>
      delete from ec_sales_tax_by_state
      </querytext>
</fullquery>

 
</queryset>
