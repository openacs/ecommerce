<?xml version="1.0"?>
<queryset>

<fullquery name="product_select">      
      <querytext>
      select * from ec_products where product_id=:product_id
      </querytext>
</fullquery>

 
<fullquery name="custom_fields_select">      
      <querytext>
      select * from ec_custom_product_field_values where product_id=:product_id
      </querytext>
</fullquery>

 
<fullquery name="categories_select">      
      <querytext>
      select category_id from ec_category_product_map where product_id=:product_id
      </querytext>
</fullquery>

 
<fullquery name="subcategories_select">      
      <querytext>
      select subcategory_id from ec_subcategory_product_map where product_id=:product_id
      </querytext>
</fullquery>

 
<fullquery name="subsubcategories_select">      
      <querytext>
      select subsubcategory_id from ec_subsubcategory_product_map where product_id=:product_id
      </querytext>
</fullquery>

 
<fullquery name="n_professional_reviews_select">      
      <querytext>
      select count(*) from ec_product_reviews where product_id = :product_id
      </querytext>
</fullquery>

 
<fullquery name="n_customer_reviews_select">      
      <querytext>
      select count(*) from ec_product_comments where product_id = :product_id
      </querytext>
</fullquery>

 
<fullquery name="n_links_to_select">      
      <querytext>
      select count(*) from ec_product_links where product_b = :product_id
      </querytext>
</fullquery>

 
<fullquery name="n_links_from_select">      
      <querytext>
      select count(*) from ec_product_links where product_a = :product_id
      </querytext>
</fullquery>

 
<fullquery name="sale_select">      
      <querytext>
      select count(*) from ec_sale_prices_current where product_id=:product_id
      </querytext>
</fullquery>

 
<fullquery name="user_class_select">      
      <querytext>
      select user_class_id, user_class_name from ec_user_classes order by user_class_name
      </querytext>
</fullquery>

 
<fullquery name="temp_price_select">      
      <querytext>
      select price from ec_product_user_class_prices where product_id=:product_id and user_class_id=:user_class_id
      </querytext>
</fullquery>

 
<fullquery name="custom_fields_select">      
      <querytext>
      select field_identifier, field_name, column_type from ec_custom_product_fields where active_p = 't'
      </querytext>
</fullquery>

 
<fullquery name="template_name_select">      
      <querytext>
      select template_name from ec_templates where template_id=:template_id
      </querytext>
</fullquery>

 
</queryset>
