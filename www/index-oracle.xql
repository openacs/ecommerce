<?xml version="1.0"?>

<queryset>
  <rdbms>
    <type>oracle</type>
    <version>8.1.6</version>
  </rdbms>

  <fullquery name="get_check_of_categories">      
    <querytext>
      select 1 
      from dual 
      where exists (select 1 
          from ec_categories)
    </querytext>
  </fullquery>

  <fullquery name="get_tl_products">      
    <querytext>
      select p.product_id, p.product_name, p.one_line_description, o.offer_code
      from ec_products_searchable p, ec_user_session_offer_codes o
      where (p.product_id(+)=o.product_id and user_session_id = :user_session_id)
      and not exists (select 1 
          from ec_category_product_map m
          where p.product_id = m.product_id)
      order by p.product_name
    </querytext>
  </fullquery>

</queryset>
