<?xml version="1.0"?>
<queryset>

<fullquery name="product_search_select">      
      <querytext>
      select product_id, sku, product_name from ec_products where $additional_query_part order by product_name
      </querytext>
</fullquery>

 
</queryset>
