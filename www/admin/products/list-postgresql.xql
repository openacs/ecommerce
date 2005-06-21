<?xml version="1.0"?>
<queryset>
  <rdbms>
    <type>postgresql</type>
    <version>7.1</version>
  </rdbms>
 
<fullquery name="product_select">      
      <querytext>
select ep.product_id, ep.product_name, ep.available_date, count(distinct eir.item_id) as n_items_ordered, count(distinct epc.comment_id) as n_comments
from ec_products ep
	LEFT JOIN ec_items_reportable eir using (product_id)
	LEFT JOIN ec_product_comments epc on (ep.product_id = epc.product_id)
group by ep.product_id, ep.product_name, ep.available_date
$category_exclusion_clause
$order_by_clause
 limit :how_many offset :start_row
      </querytext>
</fullquery>

 
</queryset>
