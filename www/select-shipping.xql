<?xml version="1.0"?>
<queryset>

  <fullquery name="get_order_id_and_order_owner">      
    <querytext>
       select order_id, user_id as order_owner
       from ec_orders 
       where user_session_id=:user_session_id and order_state='in_basket'
    </querytext>
  </fullquery>

  <fullquery name="get_an_address_id">      
    <querytext>
      select count(*) from ec_addresses where address_id=:address_id and user_id=:user_id
    </querytext>
  </fullquery>

  <fullquery name="update_ec_order_address">      
    <querytext>
      update ec_orders set shipping_address=:address_id where order_id=:order_id
    </querytext>
  </fullquery>
 
  <fullquery name="get_address_id">      
    <querytext>
      select shipping_address from ec_orders where order_id=:order_id
    </querytext>
  </fullquery>
 
  <fullquery name="shipping_avail">      
    <querytext>
      select distinct p.no_shipping_avail_p from ec_items i, ec_products p where i.product_id = p.product_id and p.no_shipping_avail_p = 't' and i.order_id = :order_id
    </querytext>
  </fullquery>
 
</queryset>
