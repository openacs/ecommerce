<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="insert_new_uc">      
      <querytext>
      insert into ec_user_classes
(user_class_id, user_class_name, last_modified, last_modifying_user, modified_ip_address)
values
(:user_class_id,:user_class_name, current_timestamp, :user_id, '[DoubleApos [ns_conn peeraddr]]')

      </querytext>
</fullquery>

 
</queryset>
