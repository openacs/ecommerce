<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<partialquery name="audit_info_sql">      
      <querytext>
      current_timestamp, :user_id, :peeraddr
      </querytext>
</partialquery>


<partialquery name="audit_update_sql">
      <querytext>
      last_modified=current_timestamp, last_modifying_user=:user_id, modified_ip_address=:peeraddr
      </querytext>
</partialquery>
 
</queryset>
