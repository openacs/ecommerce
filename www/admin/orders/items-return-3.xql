<?xml version="1.0"?>
<queryset>

  <fullquery name="get_count_refunds">      
    <querytext>
      select count(*) from ec_refunds where refund_id=:refund_id
    </querytext>
  </fullquery>

  <fullquery name="get_items_for_return">      
    <querytext>
      select i.item_id, p.product_name, coalesce(i.price_charged,0) as price_charged, coalesce(i.shipping_charged,0) as shipping_charged, coalesce(i.price_tax_charged,0) as price_tax_charged, coalesce(i.shipping_tax_charged,0) as shipping_tax_charged
      from ec_items i, ec_products p
      where i.product_id=p.product_id
      and i.item_id in ([join $item_id_list ", "])
    </querytext>
  </fullquery>
  
  <fullquery name="get_shipping_charged_values">      
    <querytext>
      select coalesce(shipping_charged,0) - coalesce(shipping_refunded,0) as base_shipping, coalesce(shipping_tax_charged,0) - coalesce(shipping_tax_refunded,0) as base_shipping_tax from ec_orders where order_id=:order_id
    </querytext>
  </fullquery>

  
  <fullquery name="get_cc_number">      
    <querytext>
      select creditcard_number from ec_orders o, ec_creditcards c where o.creditcard_id=c.creditcard_id and o.order_id=:order_id
    </querytext>
  </fullquery>

  
  <fullquery name="get_zip_code">      
    <querytext>
      select zip_code from ec_orders o, ec_addresses a where o.shipping_address=a.address_id and o.order_id=:order_id
    </querytext>
  </fullquery>

  
</queryset>
