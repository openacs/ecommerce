<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="sales_tax_update">      
      <querytext>
      
		update ec_sales_tax_by_state 
		set tax_rate=:state_tax_rate,
		shipping_p=:ship_status,
		last_modified=sysdate, 
		last_modifying_user=:user_id, 
		modified_ip_address=:ip_addr 
		where usps_abbrev=:usps_abbrev
	    
      </querytext>
</fullquery>

 
<fullquery name="sales_tax_insert">      
      <querytext>
      
		insert into ec_sales_tax_by_state
		(usps_abbrev, tax_rate, shipping_p, last_modified, last_modifying_user, modified_ip_address)
		values
		(:usps_abbrev, :state_tax_rate, :ship_status, sysdate, :user_id, :ip_addr)
	    
      </querytext>
</fullquery>

 
</queryset>
