<?xml version="1.0"?>
<queryset>

<fullquery name="products_select">      
      <querytext>
      select count(*) as n_products, round(avg(price),2) as avg_price from ec_products_displayable
      </querytext>
</fullquery>

 
</queryset>
