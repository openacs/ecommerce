<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="current_sales_select">      
      <querytext>
      select sale_price_id, sale_name, sale_price, offer_code, to_char(sale_begins,'YYYY-MM-DD HH24:MI:SS') as sale_begins, to_char(sale_ends,'YYYY-MM-DD HH24:MI:SS') as sale_ends, case when sign(current_timestamp-sale_begins) = 1 then 1 else 0 end as sale_begun_p, case when sign(current_timestamp-sale_ends) = 1 then 1 else 0 end as sale_expired_p
from ec_sale_prices_current
where product_id=:product_id
order by last_modified desc
      </querytext>
</fullquery>

 
<fullquery name="non_current_sales_select">      
      <querytext>
      select sale_price_id, sale_name, sale_price, offer_code, to_char(sale_begins,'YYYY-MM-DD HH24:MI:SS') as sale_begins, to_char(sale_ends,'YYYY-MM-DD HH24:MI:SS') as sale_ends, case when sign(current_timestamp-sale_begins) = 1 then 1 else 0 end as sale_begun_p, case when sign(current_timestamp-sale_ends) = 1 then 1 else 0 end as sale_expired_p
from ec_sale_prices
where product_id=:product_id
and (sale_begins - current_timestamp > 0 or sale_ends - current_timestamp < 0)
order by last_modified desc
      </querytext>
</fullquery>

 
</queryset>
