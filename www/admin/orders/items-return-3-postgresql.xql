<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="get_ec_tax">      
      <querytext>
      select ec_tax(:tax_price_to_refund,0,:order_id) 
      </querytext>
</fullquery>

 
<fullquery name="get_it_shipping_tax_refund">      
      <querytext>
      select ec_tax(0,$shipping_to_refund($item_id),$order_id) 
      </querytext>
</fullquery>

 
<fullquery name="get_base_shipping_it_refund">      
      <querytext>
      select ec_tax(0,:base_shipping,:order_id) 
      </querytext>
</fullquery>

 
<fullquery name="get_cash_refunded">      
      <querytext>
      select ec_cash_amount_to_refund(:total_amount_to_refund,:order_id) 
      </querytext>
</fullquery>

 
</queryset>
