<?xml version="1.0"?>
<queryset>

<fullquery name="items_needed_select">      
      <querytext>
      
    select p.product_id, p.product_name, p.sku, 
           i.color_choice, i.size_choice, i.style_choice,
           count(*) as quantity
      from ec_products p, ec_items_shippable i
     where p.product_id=i.product_id
  group by p.product_id, p.product_name, p.sku, 
           i.color_choice, i.size_choice, i.style_choice
  order by quantity desc

      </querytext>
</fullquery>

 
</queryset>
