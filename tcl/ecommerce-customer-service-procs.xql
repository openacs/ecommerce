<?xml version="1.0"?>

<queryset>

  <fullquery name="ec_customer_service_simple_issue.user_identification_select">      
    <querytext>
      select user_identification_id from ec_user_identification where user_id = :user_id
    </querytext>
  </fullquery>

  <fullquery name="ec_customer_service_simple_issue.user_identification_insert">      
    <querytext>
      insert into ec_user_identification
      (user_identification_id, user_id)
      values
      (:user_identification_id, :user_id)
    </querytext>
  </fullquery>

  <fullquery name="ec_customer_service_simple_issue.issue_type_map_insert">      
    <querytext>
      insert into ec_cs_issue_type_map
      (issue_id, issue_type)
      values
      (:issue_id, :issue_type)
    </querytext>
  </fullquery>

  <fullquery name="ec_customer_service_simple_issue.customer_service_action_insert">
    <querytext>
      insert into ec_customer_service_actions
      (action_id, issue_id, interaction_id, action_details)
      values
      (:action_id, :issue_id, :interaction_id, :action_details)
    </querytext>
  </fullquery>
  
</queryset>
