<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="get_issues_type_counts_sql">      
      <querytext>
      
      select issue_type, count(*) as n_issues
      from ec_customer_service_issues
          LEFT JOIN ec_cs_issue_type_map on
          (ec_customer_service_issues.issue_id=ec_cs_issue_type_map.issue_id)
      group by issue_type
      order by case when issue_type is null then 1 else 0 end $issue_type_decode
	
      </querytext>
</fullquery>


<fullquery name="get_info_used_query_sql">         
      <querytext>

      select info_used, count(*) as n_actions
      from ec_customer_service_actions
          LEFT JOIN ec_cs_action_info_used_map on
          (ec_customer_service_actions.action_id =
	  ec_cs_action_info_used_map.action_id)
      group by info_used
      order by case when info_used is null then 1 else 0 end $info_used_decode

      </querytext>
</fullquery>


<fullquery name="get_actions_by_originator_sql">
      <querytext>

      select interaction_originator, count(*) as n_interactions
      from ec_customer_serv_interactions
      group by interaction_originator
      order by case when interaction_originator='customer' then 0 when interaction_originator='rep' then 1 when interaction_originator='automatic' then 2 end

      </querytext>
</fullquery>


<partialquery name="initial_issue_type_decode_bit">
      <querytext>

      , case 

      </querytext>
</partialquery>


<partialquery name="middle_issue_type_decode_bit">
      <querytext>

      when issue_type='[DoubleApos $issue_type]' then $issue_type_counter

      </querytext>
</partialquery>


<partialquery name="end_issue_type_decode_bit">
      <querytext>

      else $issue_type_counter end

      </querytext>
</partialquery>



<partialquery name="initial_info_used_decode_bit">
      <querytext>

      , case 

      </querytext>
</partialquery>


<partialquery name="middle_info_used_decode_bit">
      <querytext>

      when info_used='[DoubleApos $info_used]' then $info_used_counter

      </querytext>
</partialquery>
 

<partialquery name="end_info_used_decode_bit">
      <querytext>

      else $info_used_counter end

      </querytext>
</partialquery>


</queryset>
