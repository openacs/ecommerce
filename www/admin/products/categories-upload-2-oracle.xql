<?xml version="1.0"?>
<queryset>
  <rdbms><type>oracle</type><version>7.1</version></rdbms>

  
  <fullquery name="subsubcategory_insert">
    <querytext>
      insert into ec_subsubcategory_product_map (
      	product_id,
      	subsubcategory_id,
      	publisher_favorite_p,
      	last_modified,
      	last_modifying_user,
      	modified_ip_address) 
      values (
      	:product_id,
      	:subsubcategory_id,
      	'f',
      	sysdate,
      	:user_id,
      	:ip)
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
      	sysdate,
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
      	sysdate,
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
      	sysdate,
      	:user_id,
      	:ip)
    </querytext>
  </fullquery>
  
  <fullquery name="">      
    <querytext>
    </querytext>
  </fullquery>
  
</queryset>
