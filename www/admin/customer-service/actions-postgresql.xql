<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="none_sql">
      <querytext>

      select a.action_id, a.interaction_id, a.issue_id,
      i.interaction_date, i.customer_service_rep, i.interaction_originator, i.interaction_type,
      to_char(i.interaction_date,'YYYY-MM-DD HH24:MI:SS') as full_interaction_date,
      reps.first_names as rep_first_names, reps.last_name as rep_last_name,
      i.user_identification_id, customer_info.user_id as customer_user_id,
      customer_info.first_names as customer_first_names, customer_info.last_name as customer_last_name
      from ec_customer_service_actions a, ec_customer_serv_interactions i
          LEFT JOIN cc_users reps on (i.customer_service_rep=reps.user_id),
      (select id.user_identification_id, id.user_id, u2.first_names, u2.last_name
              from ec_user_identification id LEFT JOIN cc_users u2
              on (id.user_id=u2.user_id)) customer_info
      where a.interaction_id = i.interaction_id
      and i.user_identification_id=customer_info.user_identification_id
      and 0 = (select count(*) from ec_cs_action_info_used_map map where map.action_id=a.action_id)
      $interaction_date_query_bit $rep_query_bit
      order by $order_by

      </querytext>
</fullquery>


<fullquery name="all_others_sql">
      <querytext>

      select a.action_id, a.interaction_id, a.issue_id,
      i.interaction_date, i.customer_service_rep, i.user_identification_id, i.interaction_originator, i.interaction_type,
      to_char(i.interaction_date,'YYYY-MM-DD HH24:MI:SS') as full_interaction_date,
      reps.first_names as rep_first_names, reps.last_name as rep_last_name,
      customer_info.user_id as customer_user_id, customer_info.first_names as customer_first_names, customer_info.last_name as customer_last_name
      from ec_customer_service_actions a, ec_customer_serv_interactions i
          LEFT JOIN cc_users reps
             on (i.customer_service_rep=reps.user_id), 
      ec_cs_action_info_used_map map,
      (select id.user_identification_id, id.user_id, u2.first_names, u2.last_name
          from ec_user_identification id LEFT JOIN cc_users u2
          on (id.user_id=u2.user_id)) customer_info
     where a.interaction_id = i.interaction_id
     and i.user_identification_id=customer_info.user_identification_id
     and a.action_id=map.action_id
     $info_used_query_bit
     $interaction_date_query_bit $rep_query_bit
     order by $order_by

      </querytext>
</fullquery>


<fullquery name="default_sql">
      <querytext>

      select a.action_id, a.interaction_id, a.issue_id,
      i.interaction_date, i.customer_service_rep, i.user_identification_id, i.interaction_originator, i.interaction_type,
      to_char(i.interaction_date,'YYYY-MM-DD HH24:MI:SS') as full_interaction_date,
      reps.first_names as rep_first_names, reps.last_name as rep_last_name,
      customer_info.user_id as customer_user_id, customer_info.first_names as customer_first_names, customer_info.last_name as customer_last_name
      from ec_customer_service_actions a, ec_customer_serv_interactions i, ec_cs_action_info_used_map map, cc_users reps,
      (select id.user_identification_id, id.user_id, u2.first_names, u2.last_name
          from ec_user_identification id LEFT JOIN cc_users u2
          on (id.user_id=u2.user_id)) customer_info
      where a.interaction_id = i.interaction_id
      and i.user_identification_id=customer_info.user_identification_id
      and reps.user_id=i.customer_service_rep
      and a.action_id=map.action_id
      and map.info_used=:view_info_used
      $interaction_date_query_bit $rep_query_bit
      order by $order_by

      </querytext>
</fullquery>


<partialquery name="last_24">
      <querytext>

      and now()-i.interaction_date <= timespan_days(1)

      </querytext>
</partialquery>


<partialquery name="last_week">
      <querytext>

      and now()-i.interaction_date <= timespan_days(7)

      </querytext>
</partialquery>


<partialquery name="last_month">
      <querytext>

      and now()-i.interaction_date <= '1 month'::interval

      </querytext>
</partialquery>

</queryset>
