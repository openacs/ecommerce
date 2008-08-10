<?xml version="1.0"?>

<queryset>
  <rdbms>
    <type>oracle</type>
    <version>8.1.6</version>
  </rdbms>

  <fullquery name="get_ec_product_info">      
    <querytext>
      select *
      from ec_products p, ec_custom_product_field_values v
      where p.product_id = :product_id
      and p.product_id = v.product_id(+)  and present_p = 't'
    </querytext>
  </fullquery>

  <fullquery name="find_a_good_category">      
    <querytext>
      select * 
      from (select category_id, (select count(*)
              from ec_subcategories s
              where s.category_id = m.category_id) subcount, (select count(*)
              from ec_subsubcategories ss
              where ss.subcategory_id = m.category_id) subsubcount
          from ec_category_product_map m
          where product_id = :product_id
          order by subcount, subsubcount, category_id)
      where rownum = 1
    </querytext>
  </fullquery>

</queryset>
