<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="update_ec_class_map">      
      <querytext>
      update ec_user_class_user_map
set user_class_approved_p=[ec_decode $user_class_approved_p "t" "'f'" "'t'"], last_modified=current_timestamp, last_modifying_user=:admin_user_id, modified_ip_address='[DoubleApos [ns_conn peeraddr]]'
where user_id=:user_id and user_class_id=:user_class_id
      </querytext>
</fullquery>

 
</queryset>
