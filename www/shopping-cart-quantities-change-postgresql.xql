<?xml version="1.0"?>

<queryset>
  <rdbms>
    <type>postgresql</type>
    <version>7.1</version>
  </rdbms>

  <fullquery name="insert_new_quantity_to_add">      
    <querytext>
      insert into ec_items
      (item_id, product_id, color_choice, size_choice, style_choice, order_id, in_cart_date)
      values
      (ec_item_id_sequence.nextval, :product_id, :color_choice, :size_choice, :style_choice, :order_id, current_timestamp)
    </querytext>
  </fullquery>

</queryset>
