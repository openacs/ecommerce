<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="gift_certificate_void">      
      <querytext>
      
update ec_gift_certificates
set gift_certificate_state='void',
    voided_date=sysdate,
    voided_by=:customer_service_rep,
    reason_for_void=:reason_for_void
where gift_certificate_id=:gift_certificate_id

      </querytext>
</fullquery>

 
</queryset>
