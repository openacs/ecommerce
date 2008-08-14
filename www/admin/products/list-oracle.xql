<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="product_select_count">      
      <querytext>
      select count(*) as product_count
from ec_products ep, ec_items_reportable eir, ec_product_comments epc
where ep.product_id = eir.product_id(+) 
and ep.product_id = epc.product_id(+) $category_exclusion_clause
      </querytext>
</fullquery>

<fullquery name="product_select">      
      <querytext>
        select r.*
        from (
            select rownum as r_rownum, q.*
            from (
      select ep.product_id, ep.product_name, ep.available_date, count(distinct eir.item_id) as n_items_ordered, count(distinct epc.comment_id) as n_comments
from ec_products ep, ec_items_reportable eir, ec_product_comments epc
where ep.product_id = eir.product_id(+) 
and ep.product_id = epc.product_id(+) $category_exclusion_clause
group by ep.product_id, ep.product_name, ep.available_date
$order_by_clause
            ) q
        ) r
        where r_rownum > :start_row
        and r_rownum <= :start_row + :how_many
      </querytext>
</fullquery>

 
</queryset>
