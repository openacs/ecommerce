<?xml version="1.0"?>

<queryset>
  <rdbms>
    <type>postgresql</type>
    <version>7.1</version>
  </rdbms>

  <fullquery name="get_recommended_products">      
    <querytext>
      select p.product_id, p.product_name, p.dirname, r.recommendation_text, o.offer_code
      from ec_product_recommendations r, ec_products_displayable p left outer join ec_user_session_offer_codes o on 
	(p.product_id = o.product_id and user_session_id = :user_session_id)
      where p.product_id = r.product_id
      and r.${sub}category_id=:${sub}category_id
      and r.active_p='t'
      and (r.user_class_id is null or r.user_class_id in (select user_class_id 
          from ec_user_class_user_map m 
          where user_id=:user_id
          $user_class_approved_p_clause))
      order by p.product_name
    </querytext>
  </fullquery>

  <fullquery name="get_regular_product_count">      
    <querytext>
      select count(*) as product_count
      from $product_map($sub) m, ec_products_searchable p left outer join ec_user_session_offer_codes o on
	(p.product_id = o.product_id and user_session_id = :user_session_id)
      where p.product_id = m.product_id
      and m.${sub}category_id = :${sub}category_id
      $exclude_subproducts
    </querytext>
  </fullquery>

  <fullquery name="get_regular_product_list">      
    <querytext>
      select p.product_id, p.dirname, p.product_name, p.one_line_description, o.offer_code
      from $product_map($sub) m, ec_products_searchable p left outer join ec_user_session_offer_codes o on
	(p.product_id = o.product_id and user_session_id = :user_session_id)
      where p.product_id = m.product_id
      and m.${sub}category_id = :${sub}category_id
      $exclude_subproducts
      order by p.product_name limit :how_many offset :start_row
    </querytext>
  </fullquery>

</queryset>
