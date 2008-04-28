<?xml version="1.0"?>
<queryset>

  <fullquery name="product_check">      
    <querytext>
      select product_id from ec_products 
      where sku = :sku
    </querytext>
  </fullquery>

  <fullquery name="find_subsubcategory">
    <querytext>
      select c.category_id, c.category_name, s.subcategory_id, s.subcategory_name, ss.subsubcategory_id, ss.subsubcategory_name
      from ec_subsubcategories ss, ec_subcategories s, ec_categories c
      where c.category_id = s.category_id
      and s.subcategory_id = ss.subcategory_id
      and :category_match = lower(subsubcategory_name)
    </querytext>
  </fullquery>

  <fullquery name="find_subcategory">
    <querytext>
      select c.category_id, c.category_name, s.subcategory_id,
      s.subcategory_name from ec_subcategories s, ec_categories c
      where c.category_id = s.category_id
      and :category_match = lower(subcategory_name)
    </querytext>
  </fullquery>

  <fullquery name="find_category">      
    <querytext>
      select category_id, category_name 
      from ec_categories 
      where :category_match = lower(category_name)
    </querytext>
  </fullquery>
 
</queryset>
