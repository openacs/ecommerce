<?xml version="1.0"?>
<queryset>

  <fullquery name="doubleclick_select">      
    <querytext>
      select count(*) 
      from ec_custom_product_fields 
      where field_identifier = :field_identifier
    </querytext>
  </fullquery>
  
  <fullquery name="custom_field_delete">      
    <querytext>
      delete from ec_custom_product_fields 
      where field_identifier = :field_identifier
    </querytext>
  </fullquery>

</queryset>
