<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="offers_select">      
      <querytext>
      
select o.offer_id, o.retailer_id, r.retailer_name, price, shipping,
       stock_status, special_offer_p, special_offer_html,
       shipping_unavailable_p, offer_begins, offer_ends, o.deleted_p,
       case when current_timestamp > offer_begins then 1 else 0 end as offer_begun_p,
       case when current_timestamp > offer_ends then 1 else 0 end as offer_expired_p
from ec_offers_current o, ec_retailers r
where o.retailer_id=r.retailer_id
and o.product_id=:product_id
order by o.last_modified desc

      </querytext>
</fullquery>

 
<fullquery name="non_current_offers_select">      
      <querytext>
      
select o.offer_id, o.retailer_id, retailer_name, price, shipping,
       stock_status, special_offer_p, special_offer_html,
       shipping_unavailable_p, offer_begins, offer_ends, o.deleted_p,
       case when current_timestamp > offer_begins then 1 else 0 end as offer_begun_p,
       case when current_timestamp > offer_ends then 1 else 0 end as offer_expired_p
from ec_offers o, ec_retailers r
where o.retailer_id=r.retailer_id
    and o.product_id=:product_id
    and (o.deleted_p='t' or o.offer_begins > current_timestamp or o.offer_ends < current_timestamp)
order by o.last_modified desc
      </querytext>
</fullquery>

 
</queryset>
