<?xml version="1.0"?>
<queryset>

<fullquery name="zip_code_select">      
      <querytext>
      select zip_code from ec_addresses a, ec_orders o where a.address_id=o.shipping_address and order_id=:order_id
      </querytext>
</fullquery>

 
</queryset>
