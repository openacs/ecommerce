<?xml version="1.0"?>

<queryset>
  <rdbms><type>postgresql</type><version>7.1</version></rdbms>

  <fullquery name="get_items_for_return">
    <querytext>
      select i.item_id, p.product_name, coalesce(i.price_charged,0) as price_charged, coalesce(i.shipping_charged,0) as shipping_charged, coalesce(i.price_tax_charged,0) as price_tax_charged, 
        coalesce(i.shipping_tax_charged,0) as shipping_tax_charged
      from ec_items i, ec_products p
      where i.product_id=p.product_id
      and i.item_id in ([join $item_id_list ", "])
    </querytext>
  </fullquery>

  <fullquery name="get_ec_tax">
    <querytext>
      select coalesce(ec_tax(:tax_price_to_refund, 0, :order_id),0)
    </querytext>
  </fullquery>

  <fullquery name="get_it_shipping_tax_refund">
    <querytext>
      select coalesce(ec_tax(0, $shipping_to_refund($item_id), :order_id),0) 
    </querytext>
  </fullquery>

  <fullquery name="get_shipping_charged_values">
    <querytext>
      select coalesce(shipping_charged,0) - coalesce(shipping_refunded,0) as base_shipping, coalesce(shipping_tax_charged,0) - coalesce(shipping_tax_refunded,0) as base_shipping_tax 
      from ec_orders 
      where order_id = :order_id
    </querytext>
  </fullquery>

  <fullquery name="get_base_shipping_it_refund">
    <querytext>
      select coalesce(ec_tax(0, :base_shipping, :order_id),0)
    </querytext>
  </fullquery>

  <fullquery name="get_cash_refunded">
    <querytext>
      select coalesce(ec_cash_amount_to_refund(:total_amount_to_refund, :order_id),0) 
    </querytext>
  </fullquery>

</queryset>
