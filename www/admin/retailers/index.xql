<?xml version="1.0"?>
<queryset>

<fullquery name="get_retailer_list">      
      <querytext>

   select retailer_id, 
          retailer_name, 
	  case when reach = 'web' then url else city || ', ' || usps_abbrev end as location
   from ec_retailers 
   order by retailer_name

      </querytext>
</fullquery>

 
</queryset>
