<?xml version="1.0"?>
<queryset>

<fullquery name="get_full_name">      
      <querytext>
      select first_names || ' ' || last_name from cc_users where user_id=:user_id
      </querytext>
</fullquery>

 
</queryset>
