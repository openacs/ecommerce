<?xml version="1.0"?>
<queryset>

<fullquery name="linked_products_select">      
      <querytext>
      
select product_b, product_name as product_b_name
from ec_product_links, ec_products
where product_a=:product_id
and product_b=ec_products.product_id

      </querytext>
</fullquery>

 
<fullquery name="more_links_select">      
      <querytext>
      
select product_a, product_name as product_a_name
from ec_product_links, ec_products
where product_b=:product_id
and ec_product_links.product_a=ec_products.product_id

      </querytext>
</fullquery>

 
</queryset>
