<?xml version="1.0"?>

<queryset>

  <fullquery name="get_user_name">      
    <querytext>
      select first_names || ' ' || last_name as user_name 
      from cc_users
      where user_id=:user_id
    </querytext>
  </fullquery>

  <fullquery name="get_cat_name">      
    <querytext>
      select category_name 
      from ec_categories
      where category_id=:category_id
    </querytext>
  </fullquery>

  <fullquery name="get_cat_name">      
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

  <fullquery name="get_cat_name">      
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

</queryset>
