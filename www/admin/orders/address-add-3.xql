<?xml version="1.0"?>
<queryset>

  <fullquery name="user_id_select">      
    <querytext>
      select user_id
      from ec_orders
      where order_id = :order_id
    </querytext>
  </fullquery>
  
  <fullquery name="address_insert">      
    <querytext>
      insert into ec_addresses
      (address_id, user_id, address_type, attn, line1, line2, city, usps_abbrev, full_state_name, zip_code, country_code, phone, phone_time)
      values
      (:address_id, :user_id, 'shipping', :attn, :line1, :line2, :city, :usps_abbrev, :full_state_name, :zip_code, :country_code, :phone, :phone_time)
    </querytext>
  </fullquery>
  
  <fullquery name="ec_orders_update">      
    <querytext>
      update ec_orders
      set shipping_address = :address_id
      where order_id = :order_id
    </querytext>
  </fullquery>
  
  <fullquery name="ec_orders_update">      
    <querytext>
      update ec_creditcards
      set billing_address = :address_id
      where creditcard_id = :creditcard_id
    </querytext>
  </fullquery>

</queryset>
