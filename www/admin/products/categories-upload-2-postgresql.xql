<?xml version="1.0"?>
<queryset>
  <rdbms><type>postgresql</type><version>7.1</version></rdbms>

  <fullquery name="product_check">      
    <querytext>
      select product_id from ec_products 
      where sku = :sku
    </querytext>
  </fullquery>

  <fullquery name="subcategory_insert">      
    <querytext>
      insert into ec_subcategory_product_map (
      	product_id,
      	subcategory_id,
      	publisher_favorite_p,
      	last_modified,
      	last_modifying_user,
      	modified_ip_address) 
      values (
      	:product_id,
      	:subcategory_id,
      	'f',
      	now(),
      	:user_id,
      	:ip)
    </querytext>
  </fullquery>
  
  <fullquery name="unused_sub">      
    <querytext>
      insert into ec_category_product_map (
      	product_id,
      	category_id,
      	publisher_favorite_p,
      	last_modified,
      	last_modifying_user,
      	modified_ip_address) 
      values (
      	:product_id,
      	:category_id,
      	'f',
      	now(),
      	:user_id,
      	:ip)
    </querytext>
  </fullquery>
  
  <fullquery name="category_insert">
    <querytext>
      insert into ec_category_product_map (
	product_id,
      	category_id,
      	publisher_favorite_p,
      	last_modified,
      	last_modifying_user,
      	modified_ip_address) 
      values (
      	:product_id,
      	:category_id,
      	'f',
      	now(),
      	:user_id,
      	:ip)
    </querytext>
  </fullquery>
  
  <fullquery name="">      
    <querytext>
    </querytext>
  </fullquery>
  
</queryset>
