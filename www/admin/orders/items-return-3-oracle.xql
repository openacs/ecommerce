<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="get_ec_tax">      
      <querytext>
      select ec_tax(:tax_price_to_refund,0,:order_id) from dual
      </querytext>
</fullquery>

 
<fullquery name="get_it_shipping_tax_refund">      
      <querytext>
      select ec_tax(0,$shipping_to_refund($item_id),$order_id) from dual
      </querytext>
</fullquery>

 
<fullquery name="get_shipping_charged_values">      
      <querytext>
      select nvl(shipping_charged,0) - nvl(shipping_refunded,0) as base_shipping, nvl(shipping_tax_charged,0) - nvl(shipping_tax_refunded,0) as base_shipping_tax from ec_orders where order_id=:order_id
      </querytext>
</fullquery>

 
<fullquery name="get_base_shipping_it_refund">      
      <querytext>
      select ec_tax(0,:base_shipping,:order_id) from dual
      </querytext>
</fullquery>

 
<fullquery name="get_cash_refunded">      
      <querytext>
      select ec_cash_amount_to_refund(:total_amount_to_refund,:order_id) from dual
      </querytext>
</fullquery>

 
</queryset>
