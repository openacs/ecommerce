<?xml version="1.0"?>
<queryset>

<fullquery name="get_uc_name">      
      <querytext>
      select user_class_name from ec_user_classes where user_class_id = :user_class_id
      </querytext>
</fullquery>

 
<fullquery name="get_users_in_ec_user_class">      
      <querytext>
      select 
cc.user_id, first_names, last_name, email,
m.user_class_approved_p
from cc_users cc, ec_user_class_user_map m
where cc.user_id = m.user_id
and m.user_class_id=:user_class_id
      </querytext>
</fullquery>

 
</queryset>
