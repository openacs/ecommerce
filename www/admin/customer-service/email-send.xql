<?xml version="1.0"?>
<queryset>

<fullquery name="get_user_information">
      <querytext>

select u.email as user_email, id.email as id_email
  from ec_user_identification id
  left join cc_users u using (user_id)
  where id.user_identification_id=:user_identification_id

      </querytext>
</fullquery>

 
<fullquery name="get_full_name">      
      <querytext>
      select first_names || ' ' || last_name from cc_users where user_id=:customer_service_rep
      </querytext>
</fullquery>

 
</queryset>
