<?xml version="1.0"?>

<queryset>

  <fullquery name="ec_best_price.get_min_price">      
    <querytext>
      select min(price) 
      from ec_offers
      where product_id = :product_id
    </querytext>
  </fullquery>
  
  <fullquery name="ec_savings.get_retailprice">      
    <querytext>
      select retailprice 
      from ec_custom_product_field_values
      where product_id = :product_id
    </querytext>
  </fullquery>
  
  <fullquery name="ec_savings.get_best_price">      
    <querytext>
      select min(price) 
      from ec_offers
      where product_id = :product_id
    </querytext>
  </fullquery>
  
  <fullquery name="ec_user_identification_summary.get_row_exists">      
    <querytext>
      select user_id, first_names, last_name, email, other_id_info, postal_code 
      from ec_user_identification 
      where user_identification_id = :user_identification_id
    </querytext>
  </fullquery>

  
  <fullquery name="ec_user_identification_summary.get_user_name">      
    <querytext>
      select first_names || ' ' || last_name 
      from cc_users
      where user_id = :user_id
    </querytext>
  </fullquery>
  
  <fullquery name="ec_pretty_mailing_address_from_ec_addresses.get_row_exists_p">      
    <querytext>
      select line1, line2, city, usps_abbrev, zip_code, country_code, full_state_name, attn, phone, phone_time 
      from ec_addresses
      where address_id = :address_id
    </querytext>
  </fullquery>
  
  <fullquery name="ec_creditcard_summary.get_creditcard_summary">      
    <querytext>
      select c.creditcard_type, c.creditcard_last_four, c.creditcard_expire, a.address_id
      from ec_creditcards c, ec_addresses a
      where creditcard_id = :creditcard_id
      and c.billing_address = a.address_id
    </querytext>
  </fullquery>

  <fullquery name="ec_country_name_from_country_code.country_name">
    <querytext> 
      select default_name from countries where iso = :country_code
    </querytext>
  </fullquery>
  
  <fullquery name="ec_order_status.get_shippable_p">      
    <querytext>
      select case when shipping_method = 'no shipping' then 0 else 1 end as shippable_p
      from ec_orders
      where order_id = :order_id
    </querytext>
  </fullquery>
  
  <fullquery name="ec_gift_certificate_status.get_gift_certificate_info">      
    <querytext>
      select 
      gift_certificate_state, user_id
      from ec_gift_certificates
      where gift_certificate_id = :gift_certificate_id
    </querytext>
  </fullquery>
  
  <fullquery name="ec_prune_product_purchase_combinations.prune_expired_combinations">
    <querytext>
      delete from ec_product_purchase_comb
      where exists (select product_id 
		    from ec_products p
		    where p.active_p = 'f'
		    and p.product_id in (ec_product_purchase_comb.product_id, ec_product_purchase_comb.product_0, 
					 ec_product_purchase_comb.product_1, ec_product_purchase_comb.product_2, 
					 ec_product_purchase_comb.product_3, ec_product_purchase_comb.product_4))
    </querytext>
  </fullquery>

</queryset>
