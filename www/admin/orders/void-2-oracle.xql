<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="order_update">      
      <querytext>
      
  update ec_orders
  set order_state='void',
  reason_for_void=:reason_for_void,
  voided_by=:customer_service_rep,
  voided_date=sysdate
  where order_id=:order_id
  
      </querytext>
</fullquery>

 
<fullquery name="gift_certificates_reinst">      
      <querytext>
      declare begin ec_reinst_gift_cert_on_order(:order_id); end;
      </querytext>
</fullquery>

 
</queryset>
