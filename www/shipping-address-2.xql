<?xml version="1.0"?>
<queryset>

<fullquery name="get_order_id">      
      <querytext>
      select order_id from ec_orders where user_session_id=:user_session_id and order_state='in_basket'
      </querytext>
</fullquery>

 
<fullquery name="insert_new_address">      
      <querytext>
      insert into ec_addresses
    (address_id, user_id, address_type, attn, line1, line2, city, usps_abbrev, zip_code, country_code, phone, phone_time)
    values
    (:address_id, :user_id, 'shipping', :attn, :line1,:line2,:city,:usps_abbrev,:zip_code,'us',:phone,:phone_time)
    
      </querytext>
</fullquery>

 
<fullquery name="set_shipping_on_order">      
      <querytext>
      update ec_orders set shipping_address=:address_id where order_id=:order_id
      </querytext>
</fullquery>

 
</queryset>
