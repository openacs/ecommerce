<?xml version="1.0"?>
<queryset>

<fullquery name="recommendation_select">      
      <querytext>
      select r.*, p.product_name
from  ec_recommendations_cats_view r, ec_products p
where recommendation_id=:recommendation_id
and r.product_id=p.product_id
      </querytext>
</fullquery>

 
<fullquery name="user_class_name_select">      
      <querytext>
      select user_class_name from ec_user_classes where user_class_id=:user_class_id
      </querytext>
</fullquery>

 
</queryset>
