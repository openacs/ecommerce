<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="insert_new_ec_gift_cert">      
      <querytext>
      insert into ec_gift_certificates
(gift_certificate_id, user_id, amount, expires, issue_date, issued_by, gift_certificate_state, last_modified, last_modifying_user, modified_ip_address)
values
(ec_gift_cert_id_sequence.nextval, :user_id, :amount, :expires_to_insert, sysdate, :customer_service_rep, 'authorized', sysdate, :customer_service_rep, address)

      </querytext>
</fullquery>

 
</queryset>
