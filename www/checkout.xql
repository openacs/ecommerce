<?xml version="1.0"?>

<queryset>

  <fullquery name="shipping_avail">      
    <querytext>
      select p.no_shipping_avail_p
      from ec_items i, ec_products p
      where i.product_id = p.product_id
      and p.no_shipping_avail_p = 'f' 
      and i.order_id = :order_id
      group by no_shipping_avail_p
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

  <fullquery name="update_ec_order_set_uid">      
    <querytext>
      update ec_orders
      set user_id=:user_id
      where order_id=:order_id
    </querytext>
  </fullquery>

  <fullquery name="get_user_addresses">      
    <querytext>
      select address_id, attn, line1, line2, city, usps_abbrev, zip_code, phone, country_code, full_state_name, phone_time
      from ec_addresses
      where user_id=:user_id
      and address_type='shipping'
    </querytext>
  </fullquery>

</queryset>
