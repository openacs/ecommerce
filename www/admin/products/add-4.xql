<?xml version="1.0"?>
<queryset>

<fullquery name="doubleclick_select">      
      <querytext>
      select count(*) from ec_products where product_id=:product_id
      </querytext>
</fullquery>

 
<fullquery name="user_class_select">      
      <querytext>
      select user_class_id from ec_user_classes
      </querytext>
</fullquery>

 
<fullquery name="custom_columns_select">      
      <querytext>
      
    select field_identifier
    from ec_custom_product_fields
    where active_p='t'
  
      </querytext>
</fullquery>

 
<fullquery name="custom_fields_insert">      
      <querytext>
      
  insert into ec_custom_product_field_values
  ([join $custom_columns_to_insert ", "], $audit_fields)
  values
  ([join $custom_column_values_to_insert ","], $audit_info)
  
      </querytext>
</fullquery>

 
<fullquery name="category_insert">      
      <querytext>
      
    insert into ec_category_product_map (product_id, category_id, $audit_fields)
    values
    (:product_id, :category_id, $audit_info)
    
      </querytext>
</fullquery>

 
<fullquery name="subcategory_insert">      
      <querytext>
      
    insert into ec_subcategory_product_map (
     product_id, subcategory_id, $audit_fields) values (
     :product_id, :subcategory_id, $audit_info)
      </querytext>
</fullquery>

 
<fullquery name="subsubcategory_insert">      
      <querytext>
      
    insert into ec_subsubcategory_product_map (
     product_id, subsubcategory_id, $audit_fields) values (
     :product_id, :subsubcategory_id, $audit_info)
      </querytext>
</fullquery>

 
<fullquery name="user_class_insert">      
      <querytext>
      
      insert into ec_product_user_class_prices (
      product_id, user_class_id, price, $audit_fields) values (
      :product_id, :user_class_id, :uc_price, $audit_info)
      </querytext>
</fullquery>

 
</queryset>
