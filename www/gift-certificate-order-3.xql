<?xml version="1.0"?>

<queryset>

  <fullquery name="get_zip_code">      
    <querytext>
      select zip_code 
      from ec_addresses
      where address_id=(select max(address_id) 
          from ec_addresses
          where user_id=:user_id)
    </querytext>
  </fullquery>

</queryset>
