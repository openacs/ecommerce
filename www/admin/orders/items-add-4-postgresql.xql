<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="ec_items_insert">      
      <querytext>
      insert into ec_items
  (item_id, product_id, color_choice, size_choice, style_choice, order_id, in_cart_date, item_state, price_charged, price_name)
  values
  (:item_id, :product_id, :color_choice, :size_choice, :style_choice, :order_id, current_timestamp, 'to_be_shipped', :price_charged, :price_name)
  
      </querytext>
</fullquery>

 
</queryset>
