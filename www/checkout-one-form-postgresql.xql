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

  <fullquery name="get_ec_admin_settings">      
    <querytext>
      select coalesce(base_shipping_cost,0) as base_shipping_cost, 
      coalesce(default_shipping_per_item,0) as default_shipping_per_item, 
      coalesce(weight_shipping_cost,0) as weight_shipping_cost, 
      coalesce(add_exp_base_shipping_cost,0) as add_exp_base_shipping_cost, 
      coalesce(add_exp_amount_per_item,0) as add_exp_amount_per_item, 
      coalesce(add_exp_amount_by_weight,0) as add_exp_amount_by_weight
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
      order by i.product_id
    </querytext>
  </fullquery>

  <fullquery name="select_hard_goods">      
    <querytext>
        select i.product_id, i.color_choice, i.size_choice, i.style_choice, count(*) as item_count, u.offer_code
        from ec_products p, ec_items i
        left join ec_user_session_offer_codes u on (u.product_id = i.product_id and u.user_session_id = :user_session_id)
        where i.product_id = p.product_id
        and p.no_shipping_avail_p = 'f' 
        and i.order_id = :order_id
        group by i.product_id, i.color_choice, i.size_choice, i.style_choice, u.offer_code
    </querytext>
  </fullquery>

  <fullquery name="get_order_cost">      
    <querytext>
      select ec_order_cost(:order_id) as otppgc, ec_gift_certificate_balance(:user_id) as user_gift_certificate_balance
    </querytext>
  </fullquery>

</queryset>
