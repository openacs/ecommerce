<?xml version="1.0"?>
<queryset>

<fullquery name="subcategories_select">      
      <querytext>
      
    select c.category_id, c.category_name, s.subcategory_id,
           s.subcategory_name from ec_subcategories s, ec_categories c
    where c.category_id = s.category_id
    and upper(:category) like upper(subcategory_name) || '%'
      </querytext>
</fullquery>

 
<fullquery name="category_match_select">      
      <querytext>
      select category_id, category_name from ec_categories where upper(:category) like upper(category_name) || '%'
      </querytext>
</fullquery>

 
</queryset>
