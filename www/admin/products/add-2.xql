<?xml version="1.0"?>
<queryset>

  <fullquery name="all_date_and_integer_custom_fields">      
    <querytext>
      select column_type, field_identifier, field_name
      from ec_custom_product_fields
      where column_type in ('date','integer')
      and active_p='t'
    </querytext>
  </fullquery>
  
  <fullquery name="custom_fields_select">      
    <querytext>
      select field_identifier 
      from ec_custom_product_fields
      where active_p='t'
    </querytext>
  </fullquery>
  
  <fullquery name="user_class_select">      
    <querytext>
      select user_class_id from ec_user_classes
    </querytext>
  </fullquery>
  
</queryset>
