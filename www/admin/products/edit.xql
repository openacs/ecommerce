<?xml version="1.0"?>
<queryset>

<fullquery name="product_select">      
      <querytext>
      select * from ec_products where product_id=:product_id
      </querytext>
</fullquery>

 
<fullquery name="category_list_select">      
      <querytext>
      select category_id from ec_category_product_map where product_id=:product_id
      </querytext>
</fullquery>

 
<fullquery name="subcategory_list_select">      
      <querytext>
      select subcategory_id from ec_subcategory_product_map where product_id=:product_id
      </querytext>
</fullquery>

 
<fullquery name="subsubcategory_list_select">      
      <querytext>
      select subsubcategory_id from ec_subsubcategory_product_map where product_id=:product_id
      </querytext>
</fullquery>

 
<fullquery name="num_user_classes_select">      
      <querytext>
      select count(*) from ec_user_classes
      </querytext>
</fullquery>

 
<fullquery name="user_classes_select">      
      <querytext>
      select user_class_id, user_class_name from ec_user_classes order by user_class_name
      </querytext>
</fullquery>

 
<fullquery name="price_select">      
      <querytext>
      select price from ec_product_user_class_prices where product_id=:product_id and user_class_id=:user_class_id
      </querytext>
</fullquery>

 
<fullquery name="num_custom_product_fields_select">      
      <querytext>
      select count(*) from ec_custom_product_fields where active_p='t'
      </querytext>
</fullquery>

 
<fullquery name="custom_fields_select">      
      <querytext>
      select field_identifier, field_name, default_value, column_type from ec_custom_product_fields where active_p='t' order by creation_date
      </querytext>
</fullquery>

 
<fullquery name="custom_field_value_select">      
      <querytext>
      select $field_identifier from ec_custom_product_field_values where product_id=:product_id
      </querytext>
</fullquery>

 
</queryset>
