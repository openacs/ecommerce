<?xml version="1.0"?>

<queryset>
  <rdbms><type>postgresql</type><version>7.1</version></rdbms>

  <fullquery name="product_check">      
    <querytext>
      select product_id from ec_products 
      where sku = :sku;
    </querytext>
  </fullquery>

  <fullquery name="product_update">      
    <querytext>
      update ec_products set
      last_modifying_user = :user_id,
      product_name = :product_name,
      price = :price,
      one_line_description = :one_line_description,
      detailed_description = :detailed_description,
      search_keywords = :search_keywords,
      present_p = :present_p,
      stock_status = :stock_status,
      last_modified = now(),
      color_list = :color_list,
      size_list = :size_list,
      style_list = :style_list,
      email_on_purchase_list = :email_on_purchase_list,
      url = :url,
      no_shipping_avail_p = :no_shipping_avail_p,
      shipping = :shipping,
      shipping_additional = :shipping_additional,
      weight = :weight,
      active_p = 't',
      template_id = :template_id
      where product_id = :product_id;
    </querytext>
  </fullquery>

  <fullquery name="product_insert">      
    <querytext>
      select ec_product__new(
      :product_id,
      :user_id,
      :context_id,
      :product_name, 
      :price, 
      :sku,
      :one_line_description, 
      :detailed_description, 
      :search_keywords, 
      :present_p, 
      :stock_status,
      :dirname, 
      now(),
      :color_list, 
      :size_list, 
      :peeraddr
      );
    </querytext>
  </fullquery>

  <fullquery name="product_insert_2">
    <querytext>
      update ec_products set style_list = :style_list,
      email_on_purchase_list = :email_on_purchase_list,
      url = :url,
      no_shipping_avail_p = :no_shipping_avail_p,
      shipping = :shipping,
      shipping_additional = :shipping_additional,
      weight = :weight,
      active_p = 't',
      template_id = :template_id
      where product_id = :product_id;
    </querytext>
  </fullquery>

  <fullquery name="custom_product_field_insert">      
    <querytext>
      insert into ec_custom_product_field_values (
      product_id, 
      last_modified, 
      last_modifying_user, 
      modified_ip_address) values 
      (:val_$product_id_column, 
      now(), 
      :user_id, 
      :peeraddr)
    </querytext>
  </fullquery>
  
</queryset>
