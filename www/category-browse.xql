
<?xml version="1.0"?>

<queryset>

  <fullquery name="get_full_name">      
    <querytext>
      select first_names || ' ' || last_name 
      from cc_users
      where user_id=:user_id
    </querytext>
  </fullquery>

  <fullquery name="grab_new_session_id">      
    <querytext>
      insert into ec_user_session_info 
      (user_session_id, category_id)
      values
      (:user_session_id, :category_id)
    </querytext>
  </fullquery>

  <fullquery name="get_category_name">      
    <querytext>
      select category_name 
      from ec_categories 
      where category_id=:category_id
    </querytext>
  </fullquery>

  <fullquery name="get_subcat_name">      
    <querytext>
      select subcategory_name
      from ec_subcategories 
      where subcategory_id=:subcategory_id
    </querytext>
  </fullquery>

  <fullquery name="get_subsubcat_name">      
    <querytext>
      select subsubcategory_name 
      from ec_subsubcategories 
      where subsubcategory_id=:subsubcategory_id
    </querytext>
  </fullquery>

  <fullquery name="get_subcategories">      
    <querytext>
      select * from ec_sub${sub}categories c
      where ${sub}category_id = :${sub}category_id
      and exists (select 'x' 
          from ec_products_displayable p, $product_map(sub$sub) s
          where p.product_id = s.product_id
          and s.sub${sub}category_id = c.sub${sub}category_id)
      order by sort_key, sub${sub}category_name
    </querytext>
  </fullquery>

</queryset>
