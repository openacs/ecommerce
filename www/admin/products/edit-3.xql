<?xml version="1.0"?>
<queryset>

<fullquery name="product_update">      
      <querytext>
      
  update ec_products
  set product_name=:product_name,
      sku=:sku,
      one_line_description=:one_line_description,
      detailed_description=:detailed_description,
      color_list=:color_list,
      size_list=:size_list,
      style_list=:style_list,
      email_on_purchase_list=:email_on_purchase_list,
      search_keywords=:search_keywords,
      url=:url,
      price=:price,
      no_shipping_avail_p=:no_shipping_avail_p,
      present_p=:present_p,
      available_date=:available_date,
      shipping=:shipping,
      shipping_additional=:shipping_additional,
      weight=:weight,
      template_id=:template_id,
      stock_status=:stock_status,
      $audit_update
  where product_id=:product_id
  
      </querytext>
</fullquery>

 
<fullquery name="custom_columns_select">      
      <querytext>
      select field_identifier from ec_custom_product_fields where active_p='t'
      </querytext>
</fullquery>

 
<fullquery name="num_custom_columns">      
      <querytext>
      select count(*) from ec_custom_product_field_values where product_id=:product_id
      </querytext>
</fullquery>

 
<fullquery name="custom_field_insert">      
      <querytext>
      
    insert into ec_custom_product_field_values
    ([join $custom_columns_to_insert ", "], $audit_fields)
    values
    ([join $custom_column_values_to_insert ","], $audit_info)
    
      </querytext>
</fullquery>

 
<fullquery name="custom_fields_update">      
      <querytext>
      update ec_custom_product_field_values set [join $update_list ", "], $audit_update where product_id=:product_id
      </querytext>
</fullquery>

 
<fullquery name="old_category_id_list_select">      
      <querytext>
      select category_id from ec_category_product_map where product_id=:product_id
      </querytext>
</fullquery>

 
<fullquery name="old_subcategory_id_list_select">      
      <querytext>
      select subcategory_id from ec_subcategory_product_map where product_id=:product_id
      </querytext>
</fullquery>

 
<fullquery name="old_subsubcategory_id_list_select">      
      <querytext>
      select subsubcategory_id from ec_subsubcategory_product_map where product_id=:product_id
      </querytext>
</fullquery>

 
<fullquery name="subsubcategory_delete">      
      <querytext>
      delete from ec_subsubcategory_product_map where product_id=$product_id and subsubcategory_id=:old_subsubcategory_id
      </querytext>
</fullquery>

 
<fullquery name="subcategory_delete">      
      <querytext>
      delete from ec_subcategory_product_map where product_id=:product_id and subcategory_id=:old_subcategory_id
      </querytext>
</fullquery>

 
<fullquery name="category_delete">      
      <querytext>
      delete from ec_category_product_map where product_id=:product_id and category_id=:old_category_id
      </querytext>
</fullquery>

 
<fullquery name="category_insert">      
      <querytext>
      insert into ec_category_product_map (product_id, category_id, $audit_fields) values (:product_id, :new_category_id, $audit_info)
      </querytext>
</fullquery>

 
<fullquery name="subcategory_insert">      
      <querytext>
      insert into ec_subcategory_product_map (product_id, subcategory_id, $audit_fields) values (:product_id, :new_subcategory_id, $audit_info)
      </querytext>
</fullquery>

 
<fullquery name="subsubcategory_insert">      
      <querytext>
      insert into ec_subsubcategory_product_map (product_id, subsubcategory_id, $audit_fields) values (:product_id, :new_subsubcategory_id, $audit_info)
      </querytext>
</fullquery>

 
<fullquery name="all_user_class_id_list_select">      
      <querytext>
      select user_class_id from ec_user_classes
      </querytext>
</fullquery>

 
<fullquery name="user_class_select">      
      <querytext>
      select user_class_id, price from ec_product_user_class_prices where product_id=$product_id
      </querytext>
</fullquery>

 
<fullquery name="user_class_price_delete">      
      <querytext>
      delete from ec_product_user_class_prices where user_class_id = :user_class_id
      </querytext>
</fullquery>

 
<fullquery name="user_class_price_insert">      
      <querytext>
      insert into ec_product_user_class_prices (product_id, user_class_id, price, $audit_fields) values (:product_id, :user_class_id, :user_class_price, $audit_info)
      </querytext>
</fullquery>

 
<fullquery name="user_class_price_update">      
      <querytext>
      update ec_product_user_class_prices set price=:user_class_price, $audit_update where user_class_id = :user_class_id and product_id = :product_id
      </querytext>
</fullquery>

 
</queryset>
