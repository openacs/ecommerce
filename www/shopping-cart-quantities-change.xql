<?xml version="1.0"?>

<queryset>

  <fullquery name="get_order_id">      
    <querytext>
      select order_id from ec_orders where order_state='in_basket' and user_session_id=:user_session_id
    </querytext>
  </fullquery>

  <fullquery name="">      
    <querytext>
      select i.product_id, i.color_choice, i.size_choice, i.style_choice, count(*) as r_quantity
      from ec_orders o, ec_items i
      where o.order_id=i.order_id
      and o.user_session_id=:user_session_id
      and o.order_state='in_basket'
      group by i.product_id, i.color_choice, i.size_choice, i.style_choice
    </querytext>
  </fullquery>

  <fullquery name="get_rows_to_delete">      
    <querytext>
      select max(item_id) 
      from ec_items 
      where product_id=:product_id
      and color_choice [ec_decode $color_choice "" "is null" "= :color_choice"]
      and size_choice [ec_decode $size_choice "" "is null" "= :size_choice"]
      and style_choice [ec_decode $style_choice "" "is null" "= :style_choice"]
      and order_id=:order_id $extra_condition
    </querytext>
  </fullquery>

  <fullquery name="delete_from_ec_items">      
    <querytext>
      delete from ec_items 
      where item_id in ([join $rows_to_delete ", "])
    </querytext>
  </fullquery>

</queryset>
