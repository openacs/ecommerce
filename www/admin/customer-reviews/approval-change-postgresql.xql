<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="update_set_approved_satus">      
      <querytext>
      update ec_product_comments set 
approved_p=:approved_p,
last_modified = current_timestamp,
last_modifying_user = :user_id,
modified_ip_address = '[ns_conn peeraddr]'
where comment_id=:comment_id
      </querytext>
</fullquery>

 
</queryset>
