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

  <fullquery name="get_order_id_and_order_owner">      
    <querytext>
      select order_id, user_id as order_owner
      from ec_orders 
      where user_session_id=:user_session_id 
      and order_state='in_basket'
    </querytext>
  </fullquery>

  <fullquery name="ec_order_summary_for_customer.order_details_select">      
    <querytext>
      select i.price_name, i.price_charged, i.color_choice, i.size_choice, i.style_choice, p.product_name, p.one_line_description, p.product_id, count(*) as quantity
      from ec_items i, ec_products p
      where i.order_id = :order_id
      and i.product_id = p.product_id
      group by p.product_name, p.one_line_description, p.product_id, i.price_name, i.price_charged, i.color_choice, i.size_choice, i.style_choice
    </querytext>
  </fullquery>

  <fullquery name="update_ec_order_set_uid">      
    <querytext>
      update ec_orders
      set user_id=:user_id
      where order_id=:order_id
    </querytext>
  </fullquery>

  <fullquery name="get_ec_item_count">      
    <querytext>
      select count(*) 
      from ec_items
      where order_id=:order_id
    </querytext>
  </fullquery>

  <fullquery name="get_an_address_id">     
    <querytext>
      select count(*) 
      from ec_addresses 
      where address_id = :address_id
      and user_id = :user_id
    </querytext>
  </fullquery>

  <fullquery name="get_address_id">      
    <querytext>
      select shipping_address 
      from ec_orders
      where order_id=:order_id
    </querytext>
  </fullquery>

  <fullquery name="get_names">      
    <querytext>
      select first_names, last_name 
      from cc_users
      where user_id=:user_id
    </querytext>
  </fullquery>

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

  <fullquery name="select_address">      
    <querytext>
    	select attn, line1, line2, city, usps_abbrev, zip_code, phone, country_code, full_state_name, phone_time 
    	from ec_addresses 
    	where address_id=:address_id
    </querytext>
  </fullquery>

  <fullquery name="update_address">      
    <querytext>
      update ec_addresses 
      set attn=:attn, line1=:line1, line2=:line2, city=:city, usps_abbrev=:usps_abbrev, zip_code=:zip_code, phone=:phone, phone_time=:phone_time
      where address_id=:address_id
    </querytext>
  </fullquery>

  <fullquery name="insert_new_address">      
    <querytext>
      insert into ec_addresses
      (address_id, user_id, address_type, attn, line1, line2, city, usps_abbrev, zip_code, country_code, phone, phone_time)
      values
      (:address_id, :user_id, :address_type, :attn, :line1,:line2,:city,:usps_abbrev,:zip_code,:country_code,:phone,:phone_time)
    </querytext>
  </fullquery>

  <fullquery name="select_shipping_address">
    <querytext>
    select country_code, zip_code 
    from ec_addresses
    where address_id = :address_id
    </querytext>
  </fullquery>

  <fullquery name="set_shipping_on_order">      
    <querytext>
      update ec_orders 
      set shipping_address=:address_id 
      where order_id=:order_id
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

  <fullquery name="get_shipping_info">      
    <querytext>
        select shipping, shipping_additional, weight, no_shipping_avail_p
        from ec_products
        where product_id=:product_id
    </querytext>
  </fullquery>

  <fullquery name="get_creditcards_onfile">      
    <querytext>
      select c.creditcard_id, c.creditcard_type, c.creditcard_last_four, c.creditcard_expire
      from ec_creditcards c
      where c.user_id=:user_id
      and c.creditcard_number is not null
      and c.failed_p='f'
      and 0 < (select count(*) from ec_orders o where o.creditcard_id = c.creditcard_id)
      order by c.creditcard_id desc
    </querytext>
  </fullquery>

</queryset>
