<?xml version="1.0"?>
<queryset>

<fullquery name="unused">      
      <querytext>
      
update ec_retailers
   set retailer_name=:retailer_name, 
       primary_contact_name=:primary_contact_name, 
       secondary_contact_name=:secondary_contact_name, 
       primary_contact_info=:primary_contact_info, 
       secondary_contact_info=:secondary_contact_info, 
       line1=:line1, 
       line2=:line2, 
       city=:city, 
       usps_abbrev=:usps_abbrev, 
       zip_code=:zip_code, 
       phone=:phone, 
       fax=:fax, 
       url=:url, 
       country_code=:country_code, 
       reach=:reach, 
       nexus_states=:nexus_states, 
       financing_policy=:financing_policy, 
       return_policy=:return_policy, 
       price_guarantee_policy=:price_guarantee_policy, 
       delivery_policy=:delivery_policy, 
       installation_policy=:installation_policy, 
       $audit_update
where retailer_id=:retailer_id

      </querytext>
</fullquery>

 
</queryset>
