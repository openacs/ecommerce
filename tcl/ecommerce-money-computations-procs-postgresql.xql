<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="ec_price_shipping_gift_certificate_and_tax_in_an_order.get_ec_gc_bal">      
      <querytext>
      select ec_gift_certificate_balance(:user_id) 
      </querytext>
</fullquery>

 
<fullquery name="ec_price_shipping_gift_certificate_and_tax_in_an_order.get_gc_amount">      
      <querytext>
      select ec_order_gift_cert_amount(:order_id) 
      </querytext>
</fullquery>

 
</queryset>
