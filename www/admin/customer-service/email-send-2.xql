<?xml version="1.0"?>
<queryset>

<fullquery name="check_csa_doubleclick">      
      <querytext>
      select count(*) from ec_customer_service_actions where action_id=:action_id
      </querytext>
</fullquery>

 
<fullquery name="insert_new_action_into_actions">      
      <querytext>
      insert into ec_customer_service_actions
(action_id, issue_id, interaction_id, action_details)
values
(:action_id, :issue_id, :interaction_id, :action_details)

      </querytext>
</fullquery>

 
</queryset>
