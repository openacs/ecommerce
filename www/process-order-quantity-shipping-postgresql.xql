<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="get_shipping_tax">      
      <querytext>
      select ec_tax(0,:order_shipping_cost,:order_id) 
      </querytext>
</fullquery>

 
</queryset>
