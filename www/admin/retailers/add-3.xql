<?xml version="1.0"?>
<queryset>

<fullquery name="insert_new_retailer">      
      <querytext>
      insert into ec_retailers
(retailer_id, retailer_name, primary_contact_name, secondary_contact_name, primary_contact_info, secondary_contact_info, line1, line2, city, usps_abbrev, zip_code, phone, fax, url, country_code, reach, nexus_states, financing_policy, return_policy, price_guarantee_policy, delivery_policy, installation_policy, $audit_fields)
values 
(:retailer_id, :retailer_name, :primary_contact_name, :secondary_contact_name, :primary_contact_info, :secondary_contact_info, :line1, :line2, :city, :usps_abbrev, :zip_code, :phone, :fax, :url, :country_code, :reach, :nexus_states, :financing_policy, :return_policy, :price_guarantee_policy, :delivery_policy, :installation_policy, $audit_info)

      </querytext>
</fullquery>

 
</queryset>
