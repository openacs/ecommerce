<?xml version="1.0"?>
<queryset>

<fullquery name="retailer_select">      
      <querytext>

select retailer_name, retailer_id, case when reach = 'web' then url else city || ', ' || usps_abbrev end as location
from ec_retailers order by retailer_name

      </querytext>
</fullquery>

 
</queryset>
