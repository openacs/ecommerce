<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="status_update">      
      <querytext>
      
update ec_custom_product_fields
set active_p = :active_p,
    last_modified = current_timestamp,
    last_modifying_user = :user_id,
    modified_ip_address = :peeraddr
where field_identifier = :field_identifier

      </querytext>
</fullquery>

 
</queryset>
