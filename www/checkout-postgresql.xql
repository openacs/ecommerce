<?xml version="1.0"?>

<queryset>
  <rdbms>
    <type>postgresql</type>
    <version>7.1</version>
  </rdbms>

  <fullquery name="check_order_shippable">      
    <querytext>
      select count(*)
      where exists (select 1
          from ec_products p, ec_items i
          where i.product_id = p.product_id
          and i.order_id = :order_id
          and no_shipping_avail_p = 't')
    </querytext>
  </fullquery>

</queryset>
