<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="find_a_good_category">      
      <querytext>
      FIX ME ROWNUM

    select * from 
        (select category_id,
               (select count(*)
                  from ec_subcategories s
                 where s.category_id = m.category_id) subcount,
               (select count(*)
                  from ec_subsubcategories ss
                 where ss.subcategory_id = m.category_id) subsubcount
          from ec_category_product_map m
         where product_id = :product_id
      order by subcount, subsubcount, category_id)
    where rownum = 1

      </querytext>
</fullquery>

 
</queryset>
