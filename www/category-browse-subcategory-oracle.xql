<?xml version="1.0"?>

<queryset>
  <rdbms>
    <type>oracle</type>
    <version>8.1.6</version>
  </rdbms>

  <fullquery name="get_recommended_products">      
    <querytext>
      select p.product_id, p.product_name, p.dirname, r.recommendation_text, o.offer_code
      from ec_product_recommendations r, 
      ec_products_displayable p, ec_user_session_offer_codes o
      where (p.product_id=o.product_id(+) and (user_session_id=:user_session_id or user_session_id is null))
      and p.product_id = r.product_id
      and r.${sub}category_id=:${sub}category_id
      and r.active_p='t'
      and (r.user_class_id is null or r.user_class_id in (select user_class_id 
          from ec_user_class_user_map m 
          where user_id=:user_id
          $user_class_approved_p_clause))
      order by p.product_name
    </querytext>
  </fullquery>

  <fullquery name="get_regular_product_list">      
    <querytext>
      select p.product_id, p.dirname, p.product_name, p.one_line_description, o.offer_code
      from $product_map($sub) m, ec_products_searchable p, ec_user_session_offer_codes o
      where (p.product_id=o.product_id(+) and (user_session_id=:user_session_id or user_session_id is null))
      and p.product_id = m.product_id
      and m.${sub}category_id = :${sub}category_id
      $exclude_subproducts
      order by p.product_name
    </querytext>
  </fullquery>

</queryset>
