<?xml version="1.0"?>

<queryset>

  <fullquery name="get_user_name">      
    <querytext>
      select first_names || ' ' || last_name 
      from cc_users
      where user_id=:user_id
    </querytext>
  </fullquery>

  <fullquery name="update_session_user_id">      
    <querytext>
      update ec_user_sessions
      set user_id=:user_id
      where user_session_id = :user_session_id
    </querytext>
  </fullquery>

  <fullquery name="get_produc_recs">      
    <querytext>
      select p.product_id, p.product_name, p.dirname, r.recommendation_text, o.offer_code
      from ec_product_recommendations r, ec_products_displayable p left outer join ec_user_session_offer_codes o on 
          (p.product_id = o.product_id and user_session_id = :user_session_id)
      where p.product_id=r.product_id
      and category_id is null 
      and subcategory_id is null 
      and subsubcategory_id is null
      and (r.user_class_id is null or r.user_class_id in (select user_class_id
          from ec_user_class_user_map 
          where user_id = :user_id
          $user_class_approved_p_clause))
      and r.active_p='t'
    </querytext>
  </fullquery>

</queryset>
