<?xml version="1.0"?>

<queryset>

  <fullquery name="is_product_active_p">      
    <querytext>
      select active_p 
      from ec_products 
      where product_id = :product_id
    </querytext>
  </fullquery>

</queryset>
