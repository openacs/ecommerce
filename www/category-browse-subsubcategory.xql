<?xml version="1.0"?>
<queryset>

<fullquery name="get_full_name">      
      <querytext>
      select first_names || ' ' || last_name from cc_users where user_id=:user_id
      </querytext>
</fullquery>

 
<fullquery name="grab_new_session_id">      
      <querytext>
      insert into ec_user_session_info (user_session_id, category_id) values (:user_session_id, :category_id)
      </querytext>
</fullquery>

 
<fullquery name="get_category_name">      
      <querytext>
      select category_name from ec_categories where category_id=:category_id
      </querytext>
</fullquery>

 
<fullquery name="get_subcat_name">      
      <querytext>
      select subcategory_name from ec_subcategories where subcategory_id=:subcategory_id
      </querytext>
</fullquery>

 
<fullquery name="get_subsubcat_name">      
      <querytext>
      select subsubcategory_name from ec_subsubcategories where subsubcategory_id=:subsubcategory_id
      </querytext>
</fullquery>

 
<fullquery name="get_recommended_products">      
      <querytext>
      select 
 p.product_name, p.product_id, p.dirname, r.recommendation_text
from ec_products_displayable p, ec_product_recommendations r
where p.product_id = r.product_id
and r.${sub}category_id=:${sub}category_id
and r.active_p='t'
and (r.user_class_id is null or r.user_class_id in 
      (select user_class_id 
       from ec_user_class_user_map m 
       where user_id=:user_id
       $user_class_approved_p_clause))
order by p.product_name
      </querytext>
</fullquery>

 
<fullquery name="get_regular_product_list">      
      <querytext>
      select p.product_id, p.product_name, p.one_line_description
from ec_products_searchable p, $product_map($sub) m
where p.product_id = m.product_id
and m.${sub}category_id = :${sub}category_id
$exclude_subproducts
order by p.product_name

      </querytext>
</fullquery>

 
<fullquery name="get_subcategories">      
      <querytext>
      
SELECT * from ec_sub${sub}categories c
 WHERE ${sub}category_id = :${sub}category_id
   AND exists (
       SELECT 'x' from ec_products_displayable p, $product_map(sub$sub) s
        where p.product_id = s.product_id
          and s.sub${sub}category_id = c.sub${sub}category_id
     )
 ORDER BY sort_key, sub${sub}category_name

      </querytext>
</fullquery>

 
</queryset>
