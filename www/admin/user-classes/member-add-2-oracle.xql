<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="update_ec_user_class_map">      
      <querytext>
      update ec_user_class_user_map
set user_class_approved_p='t', last_modified=sysdate, last_modifying_user=:admin_user_id, modified_ip_address='[DoubleApos [ns_conn peeraddr]]'
where user_id=:user_id and user_class_id=:user_class_id
      </querytext>
</fullquery>

 
<fullquery name="insert_new_ucm_mapping">      
      <querytext>
      insert into ec_user_class_user_map
(user_id, user_class_id, user_class_approved_p, last_modified, last_modifying_user, modified_ip_address) 
values
(:user_id, :user_class_id, 't', sysdate, :user_id, '[DoubleApos [ns_conn peeraddr]]')

      </querytext>
</fullquery>

 
</queryset>
