<?xml version="1.0"?>
<queryset>

<fullquery name="unused">      
      <querytext>
      select usps_abbrev from ec_sales_tax_by_state
      </querytext>
</fullquery>

 
<fullquery name="states_with_tax_count">      
      <querytext>
      
	    select count(*) 
	    from ec_sales_tax_by_state 
	    where usps_abbrev=:usps_abbrev
	
      </querytext>
</fullquery>

 
<fullquery name="">      
      <querytext>
      
		delete from ec_sales_tax_by_state 
		where usps_abbrev=:old_state
	    
      </querytext>
</fullquery>

 
</queryset>
