<?xml version="1.0"?>
<queryset>

<fullquery name="product_search_select">      
      <querytext>
      
select product_name, product_id
from ec_products
where upper(product_name) like '%' || upper(:product_name_query) || '%'

      </querytext>
</fullquery>

 
</queryset>
