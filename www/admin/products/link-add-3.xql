<?xml version="1.0"?>
<queryset>

<fullquery name="both_or_to_duplicate_check">      
      <querytext>
      select count(*) from ec_product_links where product_a=:link_product_id and product_b=:product_id
      </querytext>
</fullquery>

 
<fullquery name="both_or_from_duplicate_check">      
      <querytext>
      select count(*) from ec_product_links where product_a=:product_id and product_b=:link_product_id
      </querytext>
</fullquery>

 
</queryset>
