<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="update_ec_gc_info">      
      <querytext>
      update ec_gift_certificates
set expires=current_timestamp, last_modified=current_timestamp, last_modifying_user=:customer_service_rep, 
modified_ip_address= :address
where gift_certificate_id=:gift_certificate_id
      </querytext>
</fullquery>

 
</queryset>
