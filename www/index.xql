<?xml version="1.0"?>

<queryset>

  <fullquery name="get_user_name">      
    <querytext>
      select first_names || ' ' || last_name 
      from cc_users
      where user_id=:user_id
    </querytext>
  </fullquery>

  <fullquery name="update_session_user_id">      
    <querytext>
      update ec_user_sessions
      set user_id=:user_id
      where user_session_id = :user_session_id
    </querytext>
  </fullquery>

</queryset>
