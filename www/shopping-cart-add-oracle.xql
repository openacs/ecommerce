<?xml version="1.0"?>

<queryset>
  <rdbms>
    <type>oracle</type>
    <version>8.1.6</version>
  </rdbms>

  <fullquery name="insert_new_ec_order">      
    <querytext>
      insert into ec_orders
      (order_id, user_session_id, order_state, in_basket_date)
      select :order_id, :user_session_id, 'in_basket', sysdate from dual
      where not exists (select 1 
          from ec_orders 
          where user_session_id=:user_session_id 
          and order_state='in_basket')
    </querytext>
  </fullquery>

  <fullquery name="insert_problem_into_log">      
    <querytext>
      insert into ec_problems_log
      (problem_id, problem_date, problem_details)
      values
      (ec_problem_id_sequence.nextval, sysdate,:errormsg)
    </querytext>
  </fullquery>

  <fullquery name="insert_new_item_in_order">      
    <querytext>
      insert into ec_items
      (item_id, product_id, color_choice, size_choice, style_choice, order_id, in_cart_date)
      (select ec_item_id_sequence.nextval, :product_id, :color_choice, :size_choice, :style_choice, :order_id, sysdate 
      from dual
      where not exists (select 1 
          from ec_items 
          where order_id=:order_id 
          and product_id=:product_id
          and color_choice  [ec_decode $color_choice "" "is null" "= :color_choice"]  
          and size_choice [ec_decode $size_choice "" "is null" "= :size_choice"] 
          and style_choice [ec_decode $style_choice "" "is null" "= :style_choice"] 
          and ((sysdate - in_cart_date) * 86400 < 5)))
    </querytext>
  </fullquery>

</queryset>
