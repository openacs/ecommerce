<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="get_user_info">      
      <querytext>
select i.user_identification_id, i.order_id, i.closed_by, i.deleted_p, i.open_date, i.close_date, to_char(i.open_date,'YYYY-MM-DD HH24:MI:SS') as full_open_date, to_char(i.close_date,'YYYY-MM-DD HH24:MI:SS') as full_close_date, u.first_names || ' ' || u.last_name as closed_rep_name
from ec_customer_service_issues i
    left join cc_users u on (i.closed_by=u.user_id)
where issue_id=:issue_id
      </querytext>
</fullquery>


<fullquery name="get_actions_assoc_w_user">                                           <querytext> 
select a.action_id, a.interaction_id, a.action_details, a.follow_up_required, i.customer_service_rep, i.interaction_date, to_char(i.interaction_date,'YYYY-MM-DD HH24:MI:SS') as full_interaction_date, i.interaction_originator, i.interaction_type, m.info_used
from ec_customer_service_actions a
    JOIN ec_customer_serv_interactions i on (a.interaction_id=i.interaction_id)
    LEFT JOIN ec_cs_action_info_used_map m on (a.action_id=m.action_id)
where a.issue_id=:issue_id
order by a.action_id desc
      </querytext>
</fullquery>

</queryset>
