<?xml version="1.0"?>

<queryset>
  <rdbms>
    <type>postgresql</type>
    <version>7.1</version>
  </rdbms>

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
