<?xml version="1.0"?>
<queryset>

  <fullquery name="shipping_method_select">      
    <querytext>
      select shipping_method
      from ec_orders
      where order_id=:order_id
    </querytext>
  </fullquery>
  
  <fullquery name="selected_items_select">      
    <querytext>
      select i.item_id, p.product_name, p.one_line_description, p.product_id, i.price_charged, i.price_name, i.color_choice, i.size_choice, i.style_choice
      from ec_items i, ec_products p
      where i.product_id=p.product_id
      and i.order_id=:order_id
      and i.item_id in ($selected_items)
    </querytext>
  </fullquery>

  <fullquery name="all_items_select">      
    <querytext>
      select i.item_id, p.product_name, p.one_line_description, p.product_id, i.price_charged, i.price_name, i.color_choice, i.size_choice, i.style_choice
      from ec_items i, ec_products p
      where i.product_id=p.product_id
      and i.order_id=:order_id
      and i.item_state='to_be_shipped'
    </querytext>
  </fullquery>

  <fullquery name="get_pretty_mailing_address">      
    <querytext>
      select shipping_address 
      from ec_orders 
      where order_id=:order_id
    </querytext>
  </fullquery>
  
</queryset>
