<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="get_interation_originator_list">
      <querytext>
      
      select unique interaction_originator from ec_customer_serv_interactions 

      </querytext>
</fullquery>


<fullquery name="get_customer_interaction_detail">
      <querytext>

      select i.interaction_id, i.customer_service_rep, i.interaction_date,            to_char(i.interaction_date,'YYYY-MM-DD HH24:MI:SS') as full_interaction_date, i.interaction_originator,                                                         i.interaction_type, i.user_identification_id, reps.first_names as rep_first_names,                                                                              reps.last_name as rep_last_name, customer_info.user_identification_id,
      customer_info.user_id as customer_user_id, customer_info.first_names as customer_first_names,                                                                   customer_info.last_name as customer_last_name
      from ec_customer_serv_interactions i, cc_users reps,
      (select id.user_identification_id, id.user_id, u2.first_names, u2.last_name from ec_user_identification id, cc_users u2 where id.user_id=u2.user_id(+)) customer_info                                                                           where i.customer_service_rep=reps.user_id(+)
      and i.user_identification_id=customer_info.user_identification_id
      $rep_query_bit $interaction_originator_query_bit $interaction_type_query_bit $interaction_date_query_bit                                                        order by $order_by

      </querytext>
</fullquery>

 
</queryset>
