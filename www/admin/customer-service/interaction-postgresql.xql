<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="get_one_interaction_info">      
      <querytext>
      select user_identification_id, customer_service_rep, to_char(interaction_date,'YYYY-MM-DD HH24:MI:SS') as full_interaction_date, interaction_originator, interaction_type, interaction_headers from ec_customer_serv_interactions where interaction_id=:interaction_id
      </querytext>
</fullquery>

 
</queryset>
