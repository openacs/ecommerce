<?xml version="1.0"?>
<queryset>

<fullquery name="ec_best_price.get_min_price">      
      <querytext>
      select min(price) from ec_offers where product_id=:product_id
      </querytext>
</fullquery>

 
<fullquery name="ec_savings.get_retailprice">      
      <querytext>
      select retailprice from ec_custom_product_field_values where product_id=:product_id
      </querytext>
</fullquery>

 
<fullquery name="ec_savings.get_best_price">      
      <querytext>
      select min(price) from ec_offers where product_id=:product_id
      </querytext>
</fullquery>

 
<fullquery name="ec_user_identification_summary.get_row_exists">      
      <querytext>
      select user_id,first_names,last_name,email,other_id_info,postal_code from ec_user_identification where user_identification_id=:user_identification_id
      </querytext>
</fullquery>

 
<fullquery name="ec_user_identification_summary.get_user_name">      
      <querytext>
      select first_names || ' ' || last_name from cc_users where user_id=:user_id
      </querytext>
</fullquery>

 
<fullquery name="ec_pretty_mailing_address_from_ec_addresses.get_row_exists_p">      
      <querytext>
      select line1, line2, city, usps_abbrev, zip_code, country_code, full_state_name, attn, phone, phone_time from ec_addresses where address_id=:address_id
      </querytext>
</fullquery>

 
<fullquery name="ec_creditcard_summary.get_creditcard_summary">      
      <querytext>
      select creditcard_type, creditcard_last_four, creditcard_expire, billing_zip_code from ec_creditcards where creditcard_id=:creditcard_id
      </querytext>
</fullquery>


<fullquery name="ec_country_name_from_country_code.country_name">
      <querytext> 
      select default_name from country_names where iso=:country_code
      </querytext>
</fullquery>

 
<fullquery name="ec_order_status.get_shippable_p">      
      <querytext>
      select case when shipping_method = 'no shipping' then 0 else 1 end as shippable_p from ec_orders where order_id=:order_id
      </querytext>
</fullquery>

 
<fullquery name="ec_gift_certificate_status.get_gift_certificate_info">      
      <querytext>
      select 
    gift_certificate_state, user_id
    from ec_gift_certificates
    where gift_certificate_id=:gift_certificate_id
      </querytext>
</fullquery>

 
</queryset>
