<?xml version="1.0"?>
<queryset>

<fullquery name="get_user_class_name">      
      <querytext>
      select user_class_name from ec_user_classes where user_class_id=:user_class_id
      </querytext>
</fullquery>

 
<fullquery name="get_product_name">      
      <querytext>
      select product_name from ec_products where product_id=:product_id
      </querytext>
</fullquery>

 
</queryset>
