<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>


<fullquery name="get_issues_type_counts_sql">
      <querytext>

      select issue_type, count(*) as n_issues
from ec_customer_service_issues, ec_cs_issue_type_map
where ec_customer_service_issues.issue_id=ec_cs_issue_type_map.issue_id(+)
group by issue_type
order by decode(issue_type,null,1,0) $issue_type_decode

      </querytext>
</fullquery>


<fullquery name="get_info_used_query_sql">
      <querytext>

select info_used, count(*) as n_actions
from ec_customer_service_actions, ec_cs_action_info_used_map
where ec_customer_service_actions.action_id=ec_cs_action_info_used_map.action_id(+)
group by info_used
order by decode(info_used,null,1,0) $info_used_decode

      </querytext>
</fullquery>


<fullquery name="get_actions_by_originator_sql">
      <querytext>

      select interaction_originator, count(*) as n_interactions
      from ec_customer_serv_interactions
      group by interaction_originator
      order by decode(interaction_originator,'customer',0,'rep',1,'automatic',2)

      </querytext>
</fullquery>


<partialquery name="initial_issue_type_decode_bit">
      <querytext>

      , decode(issue_type,

      </querytext>
</partialquery>


<partialquery name="middle_issue_type_decode_bit">
      <querytext>

      '[DoubleApos $issue_type]',$issue_type_counter,

      </querytext>
</partialquery>


<partialquery name="end_issue_type_decode_bit">
      <querytext>

      $issue_type_counter)

      </querytext>
</partialquery>


<partialquery name="initial_info_used_decode_bit">
      <querytext>

      , decode(info_used,

      </querytext>
</partialquery>


<partialquery name="middle_info_used_decode_bit">
      <querytext>

      '[DoubleApos $info_used]',$info_used_counter,

      </querytext>
</partialquery>


<partialquery name="end_info_used_decode_bit">
      <querytext>

      $info_used_counter)

      </querytext>
</partialquery>

 
</queryset>
