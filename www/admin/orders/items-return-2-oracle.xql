<?xml version="1.0"?>

<queryset>
  <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

  <fullquery name="base_shipping_select">      
    <querytext>
      select nvl(shipping_charged,0) - nvl(shipping_refunded,0) 
      from ec_orders 
      where order_id=:order_id
    </querytext>
  </fullquery>
  
  <fullquery name="all_items_select">      
    <querytext>
      select i.item_id, p.product_name, i.price_charged, nvl(i.shipping_charged,0) as shipping_charged
      from ec_items i, ec_products p
      where i.product_id=p.product_id
      and i.item_id in ([join $item_id_list ", "])
      and i.item_state in ('shipped','arrived')  
    </querytext>
  </fullquery>

  <fullquery name="selected_items_select">      
    <querytext>
      select i.item_id, p.product_name, i.price_charged, nvl(i.shipping_charged,0) as shipping_charged
      from ec_items i, ec_products p
      where i.product_id=p.product_id
      and i.order_id=:order_id
      and i.item_state in ('shipped','arrived')
    </querytext>
  </fullquery>

</queryset>
