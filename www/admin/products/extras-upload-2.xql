<?xml version="1.0"?>
<queryset>

  <fullquery name="get_product_id_from_sku">      
    <querytext>
      select product_id from ec_products
        where sku = :sku
    </querytext>
  </fullquery>

  <fullquery name="get_custom_field_product_id">      
    <querytext>
        select product_id as custom_product_id
        from ec_custom_product_field_values 
        where product_id = :product_id
    </querytext>
  </fullquery>

</queryset>