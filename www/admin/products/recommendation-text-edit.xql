<?xml version="1.0"?>
<queryset>

<fullquery name="recommendation_select">      
      <querytext>
      select r.*, p.product_name
from ec_product_recommendations r, ec_products p
where recommendation_id=$recommendation_id

and r.product_id=p.product_id
      </querytext>
</fullquery>

 
</queryset>
