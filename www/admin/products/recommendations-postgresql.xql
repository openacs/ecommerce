<?xml version="1.0"?>
<queryset>

  <rdbms>
    <type>postgresql</type>
    <version>7.1</version>
  </rdbms>

  <fullquery name="recommendations_select">      
    <querytext>
      select r.recommendation_id, r.the_category_name, r.the_subcategory_name, r.the_subsubcategory_name, p.product_name, c.user_class_name
      from ec_recommendations_cats_view r
      join ec_products p using (product_id)
      left join ec_user_classes c on (r.user_class_id = c.user_class_id)
      where r.active_p='t'
      order by case when the_category_name is null then 0 else 1 end, upper(the_category_name), upper(the_subcategory_name), upper(the_subsubcategory_name)
    </querytext>
  </fullquery>

</queryset>
