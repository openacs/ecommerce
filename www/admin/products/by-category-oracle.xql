<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="product_categories_select">      
      <querytext>
      
select cats.category_id, cats.sort_key, cats.category_name, count(cat_view.product_id) as n_products, sum(cat_view.n_sold) as total_sold_in_category
from 
  ec_categories cats, 
  (select map.product_id, map.category_id, count(i.item_id) as n_sold
   from ec_category_product_map map, ec_items_reportable i
   where map.product_id = i.product_id(+)
   group by map.product_id, map.category_id) cat_view
where cats.category_id = cat_view.category_id(+)
group by cats.category_id, cats.sort_key, cats.category_name
order by cats.sort_key
      </querytext>
</fullquery>

 
</queryset>
