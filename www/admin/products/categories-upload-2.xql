<?xml version="1.0"?>
<queryset>

  <fullquery name="product_check">      
    <querytext>
      select product_id from ec_products 
      where sku = :sku
    </querytext>
  </fullquery>
 
</queryset>
