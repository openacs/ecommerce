<?xml version="1.0"?>

<queryset>
  <rdbms>
    <type>postgresql</type>
    <version>7.1</version>
  </rdbms>

  <fullquery name="insert_user_class">      
    <querytext>
      insert into ec_user_class_user_map 
      (user_id, user_class_id, user_class_approved_p, last_modified, last_modifying_user, modified_ip_address) 
      values 
      (:user_id, :user_class_id, null, current_timestamp, :user_id, :ip_address)
    </querytext>
  </fullquery>

</queryset>
