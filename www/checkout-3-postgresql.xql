<?xml version="1.0"?>

<queryset>
  <rdbms>
    <type>postgresql</type>
    <version>7.1</version>
  </rdbms>

  <fullquery name="get_pre_gc_price">      
    <querytext>
      select ec_order_cost(:order_id)
    </querytext>
  </fullquery>

  <fullquery name="get_gc_balance">      
    <querytext>
      select ec_gift_certificate_balance(:user_id)
    </querytext>
  </fullquery>

</queryset>
