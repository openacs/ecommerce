<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

  <fullquery name="get_user_information">      
    <querytext>
      select u.email as user_email, id.email as id_email
      from ec_user_identification id
      left join cc_users u using (user_id)
      and id.user_identification_id=:user_identification_id
    </querytext>
  </fullquery>
 
</queryset>
