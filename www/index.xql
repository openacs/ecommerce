<?xml version="1.0"?>
<queryset>

<fullquery name="get_user_name">      
      <querytext>
      select first_names || ' ' || last_name from cc_users where user_id=:user_id
      </querytext>
</fullquery>

 
<fullquery name="update_session_user_id">      
      <querytext>
      update ec_user_sessions set user_id=:user_id where user_session_id = :user_session_id
      </querytext>
</fullquery>

 
<fullquery name="get_produc_recs">      
      <querytext>
      select p.product_name, p.product_id, p.dirname, r.recommendation_text
from ec_products_displayable p, ec_product_recommendations r
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

 
<fullquery name="get_tl_products">      
      <querytext>
      select
p.product_name, p.product_id, p.one_line_description
from ec_products_searchable p
where not exists (select 1 from ec_category_product_map m where p.product_id = m.product_id)
order by p.product_name
      </querytext>
</fullquery>

 
</queryset>
