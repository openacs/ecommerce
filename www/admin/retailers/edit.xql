<?xml version="1.0"?>
<queryset>

<fullquery name="get_retailer_details">      
      <querytext>
      
select retailer_id ,
    retailer_name,
    primary_contact_name,
    secondary_contact_name,
    primary_contact_info,
    secondary_contact_info,
    line1,
    line2,
    city ,
    usps_abbrev,
    zip_code,
    phone,
    fax,
    url,
    country_code,
    reach,
    nexus_states,
    financing_policy,
    return_policy,
    
    price_guarantee_policy,
    delivery_policy,
    installation_policy
from ec_retailers 
where retailer_id=:retailer_id
      </querytext>
</fullquery>

 
</queryset>
