<?xml version="1.0"?>
<queryset>

<fullquery name="user_name_select">      
      <querytext>
      select first_names || ' ' || last_name from cc_users, ec_orders where ec_orders.user_id=cc_users.user_id and order_id=:order_id
      </querytext>
</fullquery>

 
</queryset>
