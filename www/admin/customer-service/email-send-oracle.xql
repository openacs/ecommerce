<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="get_user_information">      
      <querytext>
      
select u.email as user_email, id.email as id_email
  from cc_users u, ec_user_identification id
 where id.user_id = u.user_id(+)
   and id.user_identification_id=:user_identification_id

      </querytext>
</fullquery>

 
<fullquery name="get_new_action_id">      
      <querytext>
      select ec_action_id_sequence.nextval from dual
      </querytext>
</fullquery>

 
</queryset>
