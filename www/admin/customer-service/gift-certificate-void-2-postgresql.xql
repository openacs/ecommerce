<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="update_void_gift_c">      
      <querytext>
      update ec_gift_certificates set gift_certificate_state='void', voided_date=current_timestamp, voided_by=:customer_service_rep, reason_for_void=:reason_for_void where gift_certificate_id=:gift_certificate_id
      </querytext>
</fullquery>

 
</queryset>
