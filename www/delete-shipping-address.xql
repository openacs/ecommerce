<?xml version="1.0"?>
<queryset>

  <fullquery name="delete_address">      
    <querytext>
       update ec_addresses set address_type='deleted' where address_id=:address_id
    </querytext>
  </fullquery>
 
</queryset>
