<?xml version="1.0"?>
<queryset>

<fullquery name="retailer_select">      
      <querytext>
      
select retailer_name, retailer_id, city, usps_abbrev
from ec_retailers
order by retailer_name

      </querytext>
</fullquery>

 
<fullquery name="offer_select">      
      <querytext>
      
select price, shipping, stock_status, shipping_unavailable_p, offer_begins,
       offer_ends, special_offer_p, special_offer_html from ec_offers
where offer_id=:offer_id

      </querytext>
</fullquery>

 
</queryset>
