<?xml version="1.0"?>

<queryset>

  <fullquery name="get_order_id">      
    <querytext>
      select order_id 
      from ec_orders 
      where user_session_id=:user_session_id 
      and order_state='in_basket'
    </querytext>
  </fullquery>

  <fullquery name="get_gc_id">      
    <querytext>
      select gift_certificate_id 
      from ec_gift_certificates 
      where claim_check=:claim_check
    </querytext>
  </fullquery>

  <fullquery name="get_gc_user_id">      
    <querytext>
      select user_id as gift_certificate_user_id, amount 
      from ec_gift_certificates 
      where gift_certificate_id=:gift_certificate_id
    </querytext>
  </fullquery>

  <fullquery name="get_cc_owner">      
    <querytext>
      select user_id
      from ec_creditcards 
      where creditcard_id=:creditcard_id
    </querytext>
  </fullquery>

  <fullquery name="get_shipping_address_ids">      
    <querytext>
        select address_id
        from ec_addresses
        where user_id=:user_id
        and address_type = 'shipping'
    </querytext>
  </fullquery>

  <fullquery name="use_existing_cc_for_order">      
    <querytext>
      update ec_orders
      set creditcard_id=:creditcard_id
      where order_id=:order_id
    </querytext>
  </fullquery>

  <fullquery name="insert_new_cc">      
    <querytext>
      insert into ec_creditcards
      (creditcard_id, user_id, creditcard_number, creditcard_last_four, creditcard_type, creditcard_expire, billing_address)
      values
      (:creditcard_id, :user_id, :creditcard_number, :cc_no , :creditcard_type, :expiry, :billing_address_id)
    </querytext>
  </fullquery>

  <fullquery name="update_cc_address">      
    <querytext>
      update ec_creditcards
      set billing_address = :billing_address_id
      where creditcard_id = :creditcard_id
    </querytext>
  </fullquery>

  <fullquery name="update_order_set_cc">      
    <querytext>
      update ec_orders
      set creditcard_id=:creditcard_id
      where order_id=:order_id
    </querytext>
  </fullquery>

  <fullquery name="set_null_cc_in_order">      
    <querytext>
      update ec_orders
      set creditcard_id=null
      where order_id=:order_id
    </querytext>
  </fullquery>

  <fullquery name="update_address">      
    <querytext>
      update ec_addresses 
      set attn=:attn, line1=:line1, line2=:line2, city=:city, usps_abbrev=:usps_abbrev, zip_code=:zip_code, phone=:phone, phone_time=:phone_time
      where address_id=:address_id
    </querytext>
  </fullquery>

  <fullquery name="update_ec_items">      
    <querytext>
      update ec_items 
      set price_charged=round(:price_charged,2), price_name=:price_name, shipping_charged=round(:shipping_charged,2), price_tax_charged=round(:tax_charged,2), shipping_tax_charged=round(:shipping_tax,2) 
      where item_id=:item_id
    </querytext>
  </fullquery>

  <fullquery name="set_shipping_on_order">      
    <querytext>
      update ec_orders 
      set shipping_address=:address_id 
      where order_id=:order_id
    </querytext>
  </fullquery>

  <fullquery name="update_shipping_method">      
    <querytext>
      update ec_orders
      set shipping_method=:shipping_method,
      tax_exempt_p=:tax_exempt_p
      where order_id=:order_id
    </querytext>
  </fullquery>

  <fullquery name="get_list_user_classes">      
    <querytext>
      select user_class_id 
      from ec_user_class_user_map
      where user_id=:user_id $additional_user_class_restriction
    </querytext>
  </fullquery>

  <fullquery name="get_order_id">      
    <querytext>
      select order_id 
      from ec_orders 
      where user_session_id=:user_session_id 
      and order_state='in_basket'
    </querytext>
  </fullquery>

  <fullquery name="select_address">
    <querytext>
      select attn, line1, line2, city, usps_abbrev, zip_code, phone, country_code, full_state_name, phone_time 
      from ec_addresses 
      where address_id=:address_id
      and user_id=:user_id
    </querytext>
  </fullquery>

  <fullquery name="update_address">
    <querytext>
      update ec_addresses
      set attn = :attn, line1 = :line1, line2 = :line2, usps_abbrev = :usps_abbrev, 
      city = :city, full_state_name = :full_state_name, zip_code = :zip_code, country_code = :country_code, phone = :phone, phone_time = :phone_time
      where address_id = :address_id
    </querytext>
  </fullquery>

  <fullquery name="get_usps_abbrev">      
    <querytext>
      select usps_abbrev 
      from ec_addresses
      where address_id=:address_id
    </querytext>
  </fullquery>

  <fullquery name="get_tax_rate">      
    <querytext>
      select tax_rate, shipping_p 
      from ec_sales_tax_by_state
      where usps_abbrev=:usps_abbrev
    </querytext>
  </fullquery>

  <fullquery name="set_shipping_on_order">
    <querytext>
      update ec_orders 
      set shipping_address=:address_id 
      where order_id=:order_id
    </querytext>
  </fullquery>

  <fullquery name="insert_new_address">      
    <querytext>
      insert into ec_addresses
        (address_id, user_id, address_type, attn, line1, line2, city, usps_abbrev, full_state_name, zip_code, country_code, phone, phone_time)
        values
        (:address_id, :user_id, :address_type, :attn,:line1,:line2,:city,:usps_abbrev,:full_state_name,:zip_code,:country_code,:phone,:phone_time)
    </querytext>
  </fullquery>

  <fullquery name="update_order_shipping_address">      
    <querytext>
      update ec_orders 
      set shipping_address=:address_id 
      where order_id=:order_id
    </querytext>
  </fullquery>

  <fullquery name="get_shipping_per_item">      
    <querytext>
      select default_shipping_per_item, weight_shipping_cost 
      from ec_admin_settings
    </querytext>
  </fullquery>

  <fullquery name="get_exp_amt_peritem">      
    <querytext>
      select add_exp_amount_per_item, add_exp_amount_by_weight 
      from ec_admin_settings
    </querytext>
  </fullquery>

  <fullquery name="set_shipping_charges">      
    <querytext>
      update ec_orders 
      set shipping_charged=round(:order_shipping_cost,2), shipping_tax_charged=round(:tax_on_order_shipping_cost,2) 
      where order_id=:order_id
    </querytext>
  </fullquery>

</queryset>
