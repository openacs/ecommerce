<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="get_new_csa_seq_id">      
      <querytext>
      select ec_interaction_id_sequence.nextval 
      </querytext>
</fullquery>

 
<fullquery name="insert_new_cs_interaction">      
      <querytext>
      insert into ec_customer_serv_interactions
(interaction_id, customer_service_rep, user_identification_id, interaction_date, interaction_originator, interaction_type)
values
(:interaction_id, :customer_service_rep, :user_identification_id, current_timestamp, 'rep', 'email')

      </querytext>
</fullquery>

 
</queryset>
