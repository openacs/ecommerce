<?xml version="1.0"?>

<queryset>
  <rdbms>
    <type>oracle</type>
    <version>8.1.6</version>
  </rdbms>

  <fullquery name="get_ec_admin_settings">
    <querytext>
    select nvl(base_shipping_cost,0) as base_shipping_cost, 
    nvl(default_shipping_per_item,0) as default_shipping_per_item, 
    nvl(weight_shipping_cost,0) as weight_shipping_cost, 
    nvl(add_exp_base_shipping_cost,0) as add_exp_base_shipping_cost, 
    nvl(add_exp_amount_per_item,0) as add_exp_amount_per_item, 
    nvl(add_exp_amount_by_weight,0) as add_exp_amount_by_weight
    from ec_admin_settings
    </querytext>
  </fullquery>

  <fullquery name="get_products_in_cart">      
    <querytext>
    select p.product_name, p.one_line_description, p.no_shipping_avail_p, p.shipping, p.shipping_additional, p.weight, p.product_id, count(*) as quantity, u.offer_code, i.color_choice, i.size_choice, i.style_choice, '' as price
    from ec_orders o, ec_items i, ec_products p, 
        (select product_id, offer_code from ec_user_session_offer_codes usoc where usoc.user_session_id=:user_session_id) u
    where i.product_id=p.product_id
    and o.order_id=i.order_id
    and p.product_id=u.product_id(+)
    and o.user_session_id=:user_session_id and o.order_state='in_basket'
    group by p.product_name, p.one_line_description, p.no_shipping_avail_p, p.shipping, p.shipping_additional, p.weight, p.product_id, u.offer_code, i.color_choice, i.size_choice, i.style_choice
    </querytext>
  </fullquery>

  <fullquery name="select_hard_goods">      
    <querytext>
      select i.product_id, i.color_choice, i.size_choice, i.style_choice, count(*) as item_count, u.offer_code
      from ec_products p, ec_items i, ec_user_session_offer_codes u
      where u.product_id(+)=i.product_id and (u.user_session_id is null or u.user_session_id=:user_session_id)
      and i.product_id = p.product_id
      and p.no_shipping_avail_p = 'f' 
      and i.order_id = :order_id
      group by i.product_id, i.color_choice, i.size_choice, i.style_choice, u.offer_code
    </querytext>
  </fullquery>

</queryset>
