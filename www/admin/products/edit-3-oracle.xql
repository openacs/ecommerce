<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<partialquery name="audit_info_sql">      
      <querytext>
      sysdate, :user_id, :peeraddr
      </querytext>
</partialquery>


<partialquery name="audit_update_sql">
      <querytext>
      last_modified=sysdate, last_modifying_user=:user_id, modified_ip_address=:peeraddr
      </querytext>
</partialquery>
 
</queryset>
