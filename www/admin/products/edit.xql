<?xml version="1.0"?>
<queryset>

<fullquery name="product_select">      
      <querytext>
select product_id, sku, product_name,                                           to_char(creation_date, 'YYYY-MM-DD') as creation_date, one_line_description,    detailed_description, search_keywords, price, no_shipping_avail_p, shipping,    shipping_additional, weight, dirname, present_p, active_p,                      to_char(available_date, 'YYYY-MM-DD') as available_date, announcements,         to_char(announcements_expire, 'YYYY-MM-DD') as announcements_expire, url,       template_id, stock_status, color_list, size_list, style_list,                   email_on_purchase_list, to_char(last_modified, 'YYYY-MM-DD') as last_modified,  last_modifying_user, modified_ip_address                                        from ec_products where product_id=:product_id
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
