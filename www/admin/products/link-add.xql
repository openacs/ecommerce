<?xml version="1.0"?>
<queryset>

<fullquery name="product_search_select">      
      <querytext>
      select product_id as link_product_id, product_name as link_product_name from ec_products where $additional_query_part
      </querytext>
</fullquery>

 
</queryset>
