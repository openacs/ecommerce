<?xml version="1.0"?>

<queryset>
  <rdbms>
    <type>postgresql</type>
    <version>7.1</version>
  </rdbms>

  <fullquery name="get_shipping_tax">      
    <querytext>
      select ec_tax(0,:order_shipping_cost,:order_id)
    </querytext>
  </fullquery>

  <fullquery name="get_base_ship_cost">      
    <querytext>
      select coalesce(base_shipping_cost,0) 
      from ec_admin_settings
    </querytext>
  </fullquery>

  <fullquery name="get_exp_base_cost">      
    <querytext>
      select coalesce(add_exp_base_shipping_cost,0) 
      from ec_admin_settings
    </querytext>
  </fullquery>

  <fullquery name="get_items_in_cart">      
    <querytext>
      select i.item_id, i.product_id, u.offer_code
      from ec_items i
      left join (select * 
          from ec_user_session_offer_codes usoc 
          where usoc.user_session_id=:user_session_id) u on (i.product_id=u.product_id)
      where i.order_id=:order_id
    </querytext>
  </fullquery>

</queryset>
