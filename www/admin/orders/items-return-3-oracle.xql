<?xml version="1.0"?>

<queryset>
  <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

  <fullquery name="get_items_for_return">
    <querytext>
      select i.item_id, p.product_name, nvl(i.price_charged,0) as price_charged, nvl(i.shipping_charged,0) as shipping_charged, 
        nvl(i.price_tax_charged,0) as price_tax_charged, nvl(i.shipping_tax_charged,0) as shipping_tax_charged
      from ec_items i, ec_products p
      where i.product_id=p.product_id
      and i.item_id in ([join $item_id_list ", "])
    </querytext>
  </fullquery>

  <fullquery name="get_ec_tax">
    <querytext>
      select nvl(ec_tax(:tax_price_to_refund, 0, :order_id),0) 
      from dual
    </querytext>
  </fullquery>

  <fullquery name="get_it_shipping_tax_refund">
    <querytext>
      select nvl(ec_tax(0, $shipping_to_refund($item_id), :order_id),0) 
      from dual
    </querytext>
  </fullquery>

  <fullquery name="get_shipping_charged_values">
    <querytext>
      select nvl(shipping_charged,0) - nvl(shipping_refunded,0) as base_shipping, nvl(shipping_tax_charged,0) - nvl(shipping_tax_refunded,0) as base_shipping_tax 
      from ec_orders 
      where order_id = :order_id
    </querytext>
  </fullquery>

  <fullquery name="get_base_shipping_it_refund">
    <querytext>
      select nvl(ec_tax(0, :base_shipping, :order_id),0)
      from dual
    </querytext>
  </fullquery>

  <fullquery name="get_cash_refunded">
    <querytext>
      select nvl(ec_cash_amount_to_refund(:total_amount_to_refund, :order_id),0)
      from dual
    </querytext>
  </fullquery>

</queryset>
