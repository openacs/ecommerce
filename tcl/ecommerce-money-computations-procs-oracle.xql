<?xml version="1.0"?>

<queryset>
  <rdbms>
    <type>oracle</type>
    <version>8.1.6</version>
  </rdbms>

  <fullquery name="ec_price_shipping_gift_certificate_and_tax_in_an_order.get_ec_gc_bal">      
    <querytext>
      select ec_gift_certificate_balance(:user_id) from dual
    </querytext>
  </fullquery>
  
  <fullquery name="ec_price_shipping_gift_certificate_and_tax_in_an_order.get_gc_amount">      
    <querytext>
      select ec_order_gift_cert_amount(:order_id) from dual
    </querytext>
  </fullquery>
  
</queryset>
