<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>
 
<fullquery name="insert_new_cs_interaction">      
      <querytext>
      insert into ec_customer_serv_interactions
(interaction_id, customer_service_rep, user_identification_id, interaction_date, interaction_originator, interaction_type)
values
(:interaction_id, :customer_service_rep, :user_identification_id, sysdate, 'rep', 'email')

      </querytext>
</fullquery>

 
</queryset>
