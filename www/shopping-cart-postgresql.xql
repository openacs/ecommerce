<?xml version="1.0"?>

<queryset>
  <rdbms>
    <type>postgresql</type>
    <version>7.1</version>
  </rdbms>

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

  <fullquery name="get_products_in_cart">      
    <querytext>
      select p.product_name, p.one_line_description, p.no_shipping_avail_p, p.shipping, p.shipping_additional, p.weight, p.product_id, count(*) as quantity, u.offer_code, i.color_choice, i.size_choice, i.style_choice, '' as price 
      from ec_orders o
      join ec_items i on (o.order_id=i.order_id)
      join ec_products p on (i.product_id=p.product_id)
      left join (select product_id, offer_code 
	  from ec_user_session_offer_codes usoc 
	  where usoc.user_session_id=:user_session_id) u on (p.product_id=u.product_id)
      where o.user_session_id=:user_session_id 
      and o.order_state='in_basket'
      group by p.product_name, p.one_line_description, p.no_shipping_avail_p, p.shipping, p.shipping_additional, p.weight, p.product_id, u.offer_code, i.color_choice, i.size_choice, i.style_choice
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

</queryset>
