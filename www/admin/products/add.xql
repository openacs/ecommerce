<?xml version="1.0"?>
<queryset>

<fullquery name="num_user_classes_select">      
      <querytext>
      select count(*) from ec_user_classes
      </querytext>
</fullquery>

 
<fullquery name="user_class_select">      
      <querytext>
      
    select user_class_id, 
           user_class_name 
    from ec_user_classes 
    order by user_class_name
      </querytext>
</fullquery>

 
<fullquery name="num_custom_product_fields_select">      
      <querytext>
      select count(*) from ec_custom_product_fields where active_p='t'
      </querytext>
</fullquery>

 
<fullquery name="custom_fields_select">      
      <querytext>
      
    select field_identifier, 
           field_name, 
           default_value, 
           column_type 
    from ec_custom_product_fields 
    where active_p='t' order by creation_date
      </querytext>
</fullquery>

 
</queryset>
