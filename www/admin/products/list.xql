<?xml version="1.0"?>
<queryset>

<fullquery name="category_name_select">      
      <querytext>
      select category_name from ec_categories where category_id = :category_id
      </querytext>
</fullquery>

 
<fullquery name="product_select">      
      <querytext>

select ep.product_id, ep.product_name, ep.available_date, count(distinct eir.item_id) as n_items_ordered, count(distinct epc.comment_id) as n_comments
from ec_products ep
	LEFT JOIN ec_items_reportable eir using (product_id)
	LEFT JOIN ec_product_comments epc on (ep.product_id = epc.product_id)
	$category_exclusion_clause
group by ep.product_id, ep.product_name, ep.available_date
$order_by_clause

      </querytext>
</fullquery>

 
</queryset>
