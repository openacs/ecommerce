<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="update_ec_gc_info">      
      <querytext>
      update ec_gift_certificates
set expires=sysdate, last_modified=sysdate, last_modifying_user=:customer_service_rep, 
modified_ip_address= :address
where gift_certificate_id=:gift_certificate_id
      </querytext>
</fullquery>

 
</queryset>
