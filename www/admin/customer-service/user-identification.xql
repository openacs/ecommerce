<?xml version="1.0"?>
<queryset>

<fullquery name="get_user_id_info">      
      <querytext>
      select * from ec_user_identification where user_identification_id=:user_identification_id
      </querytext>
</fullquery>

 
<fullquery name="get_row_exists_name">      
      <querytext>
      select first_names as d_first_names, last_name as d_last_name, user_id as d_user_id from cc_users where email = lower(:email)
      </querytext>
</fullquery>

 
</queryset>
