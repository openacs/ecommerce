<?xml version="1.0"?>

<queryset>
  <rdbms>
    <type>postgresql</type>
    <version>7.1</version>
  </rdbms>

  <fullquery name="shipping_method_counts">      
    <querytext>
      select shipping_method, coalesce(count(*), 0) as shipping_method_count
    from ec_orders_shippable
    where shipping_method not in ('no_shipping', 'pickup')
    and shipping_method is not null
    group by shipping_method
    </querytext>
  </fullquery>

</queryset>
