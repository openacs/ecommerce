<?xml version="1.0"?>
<queryset>

  <rdbms>
    <type>oracle</type>
    <version>8.1.6</version>
  </rdbms>

  <fullquery name="recommendations_select">      
    <querytext>
      select r.recommendation_id, r.the_category_name, r.the_subcategory_name, r.the_subsubcategory_name, p.product_name, c.user_class_name
      from ec_recommendations_cats_view r, ec_products p, ec_user_classes c
      where r.product_id=p.product_id and r.user_class_id = c.user_class_id(+) and r.active_p='t'
      order by DECODE(the_category_name,null,0,1), upper(the_category_name), 
      upper(the_subcategory_name),
      upper(the_subsubcategory_name)
    </querytext>
  </fullquery>

</queryset>
