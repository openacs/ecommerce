<?xml version="1.0"?>
<queryset>

<fullquery name="order_count_select">      
      <querytext>
      select count(*) from ec_items where product_id=:product_id
      </querytext>
</fullquery>

 
<fullquery name="offer_list_select">      
      <querytext>
      select offer_id from ec_offers where product_id=:product_id
      </querytext>
</fullquery>

 
<fullquery name="offers_delete">      
      <querytext>
      delete from ec_offers where product_id=:product_id
      </querytext>
</fullquery>

 
<fullquery name="custom_product_fields_delete">      
      <querytext>
      delete from ec_custom_product_field_values where product_id=:product_id
      </querytext>
</fullquery>

 
<fullquery name="subsubcategory_list_select">      
      <querytext>
      select subsubcategory_id from ec_subsubcategory_product_map where product_id=:product_id
      </querytext>
</fullquery>

 
<fullquery name="subsubcategory_delete">      
      <querytext>
      delete from ec_subsubcategory_product_map where product_id=:product_id
      </querytext>
</fullquery>

 
<fullquery name="subcategory_list_select">      
      <querytext>
      select subcategory_id from ec_subcategory_product_map where product_id=:product_id
      </querytext>
</fullquery>

 
<fullquery name="subcategory_delete">      
      <querytext>
      delete from ec_subcategory_product_map where product_id=:product_id
      </querytext>
</fullquery>

 
<fullquery name="category_list_select">      
      <querytext>
      select category_id from ec_category_product_map where product_id=:product_id
      </querytext>
</fullquery>

 
<fullquery name="category_delete">      
      <querytext>
      delete from ec_category_product_map where product_id=:product_id
      </querytext>
</fullquery>

 
<fullquery name="review_list_select">      
      <querytext>
      select review_id from ec_product_reviews where product_id=:product_id
      </querytext>
</fullquery>

 
<fullquery name="review_delete">      
      <querytext>
      delete from ec_product_reviews where product_id=:product_id
      </querytext>
</fullquery>

 
<fullquery name="product_comments_delete">      
      <querytext>
      delete from ec_product_comments where product_id=:product_id
      </querytext>
</fullquery>

 
<fullquery name="product_a_list_select">      
      <querytext>
      select product_a from ec_product_links where product_b=:product_id
      </querytext>
</fullquery>

 
<fullquery name="product_b_list_select">      
      <querytext>
      select product_b from ec_product_links where product_a=:product_id
      </querytext>
</fullquery>

 
<fullquery name="links_delete">      
      <querytext>
      delete from ec_product_links where product_a=:product_id or product_b=:product_id
      </querytext>
</fullquery>

 
<fullquery name="user_class_select">      
      <querytext>
      select user_class_id, price from ec_product_user_class_prices where product_id=:product_id
      </querytext>
</fullquery>

 
<fullquery name="delete_from_session_info">      
      <querytext>
      delete from ec_user_session_info where product_id=:product_id
      </querytext>
</fullquery>

 
<fullquery name="user_class_prices_delete">      
      <querytext>
      delete from ec_product_user_class_prices where product_id=:product_id
      </querytext>
</fullquery>

 
<fullquery name="series_id_list_select">      
      <querytext>
      select series_id from ec_product_series_map where component_id=:product_id
      </querytext>
</fullquery>

 
<fullquery name="component_id_list_select">      
      <querytext>
      select component_id from ec_product_series_map where series_id=:product_id
      </querytext>
</fullquery>

 
<fullquery name="series_delete">      
      <querytext>
      delete from ec_product_series_map where series_id=:product_id or component_id=:product_id
      </querytext>
</fullquery>

 
<fullquery name="sale_price_list_select">      
      <querytext>
      select sale_price_id from ec_sale_prices where product_id=:product_id
      </querytext>
</fullquery>

 
<fullquery name="sale_price_delete">      
      <querytext>
      delete from ec_sale_prices where product_id=:product_id
      </querytext>
</fullquery>

 
</queryset>
