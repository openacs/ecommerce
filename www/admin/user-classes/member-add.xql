<?xml version="1.0"?>
<queryset>

<fullquery name="get_users_for_map">      
      <querytext>
      select user_id, first_names, last_name, email
from cc_users
where $last_bit_of_query
      </querytext>
</fullquery>

 
</queryset>
