<?xml version="1.0"?>
<queryset>

<fullquery name="product_reviews_select">      
      <querytext>
      
select review_id, author_name, publication, review_date, display_p
from ec_product_reviews
where product_id=:product_id

      </querytext>
</fullquery>

 
</queryset>
