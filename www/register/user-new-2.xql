<?xml version="1.0"?>
<queryset>

<fullquery name="user_exists">      
      <querytext>
      select count(*) from registered_users where user_id = :user_id
      </querytext>
</fullquery>

 
</queryset>
