<?xml version="1.0"?>

<queryset>

  <fullquery name="get_product_name">      
    <querytext>
      select product_name 
      from ec_products 
      where product_id=:product_id
    </querytext>
  </fullquery>

</queryset>
