<?xml version="1.0"?>
<queryset>

<fullquery name="get_service_action_count">      
      <querytext>
      select count(*) from ec_customer_service_actions where action_id=:action_id
      </querytext>
</fullquery>

 
<fullquery name="get_user_id_info">      
      <querytext>
      select i.user_identification_id as c_user_identification_id, a.interaction_id
	from ec_customer_service_actions a, ec_customer_serv_interactions i
	where i.interaction_id=a.interaction_id
	and a.action_id=:action_id
      </querytext>
</fullquery>

 
<fullquery name="get_user_issue_id_info">      
      <querytext>
      select u.user_id as issue_user_id, u.user_identification_id as issue_user_identification_id
    from ec_user_identification u, ec_customer_service_issues i
    where u.user_identification_id = i.user_identification_id
    and i.issue_id=:issue_id
      </querytext>
</fullquery>

 
<fullquery name="get_full_name">      
      <querytext>
      select first_names || ' ' || last_name from cc_users where user_id=:issue_user_id
      </querytext>
</fullquery>

 
<fullquery name="get_user_id">      
      <querytext>
      select user_id from ec_user_identification where user_identification_id=:c_user_identification_id
      </querytext>
</fullquery>

 
<fullquery name="get_full_name">      
      <querytext>
      select first_names || ' ' || last_name from cc_users where user_id=:issue_user_id
      </querytext>
</fullquery>

 
<fullquery name="get_order_owner">      
      <querytext>
      select user_id as order_user_id from ec_orders where order_id=:order_id
      </querytext>
</fullquery>

 
<fullquery name="get_user_name">      
      <querytext>
      select first_names || ' ' || last_name from cc_users where user_id=:order_user_id
      </querytext>
</fullquery>

 
<fullquery name="get_user_id_user">      
      <querytext>
      select user_id from ec_user_identification where user_identification_id=:c_user_identification_id
      </querytext>
</fullquery>

 
<fullquery name="get_uiid_to_insert">      
      <querytext>
      select user_identification_id as uiid_to_insert from ec_user_identification where user_id=:d_user_id
      </querytext>
</fullquery>

 
<fullquery name="insert_new_uiid">      
      <querytext>
      insert into ec_user_identification
	    (user_identification_id, user_id, email, first_names, last_name, postal_code, other_id_info)
	    values
	    (:uiid_to_insert, :user_id_to_insert, :email,:first_names,:last_name,:postal_code,:other_id_info)
	    
      </querytext>
</fullquery>

 
<fullquery name="insert_new_cs_interaction">      
      <querytext>
      insert into ec_customer_serv_interactions
    (interaction_id, customer_service_rep, user_identification_id, interaction_date, interaction_originator, interaction_type)
    values
    (:interaction_id, :customer_service_rep, :uiid_to_insert, $date_string, :interaction_originator, [ec_decode $interaction_type "other" ":interaction_type_other" ":interaction_type"])
    
      </querytext>
</fullquery>

 
<fullquery name="insert_new_ec_cs_issue">      
      <querytext>
      insert into ec_customer_service_issues
    (issue_id, user_identification_id, order_id, open_date, close_date, closed_by)
    values
    (:issue_id, :uiid_to_insert, :order_id, $date_string, [ec_decode $close_issue_p "t" ":date_string" "''"], [ec_decode $close_issue_p "t" ":customer_service_rep" "''"])
    
      </querytext>
</fullquery>

 
<fullquery name="insert_into_issue_tm">      
      <querytext>
      insert into ec_cs_issue_type_map
	(issue_id, issue_type)
	values
	(:issue_id, :issue_type)
	
      </querytext>
</fullquery>

 
<fullquery name="insert_new_ec_service_action">      
      <querytext>
      insert into ec_customer_service_actions
(action_id, issue_id, interaction_id, action_details, follow_up_required)
values
(:action_id, :issue_id, :interaction_id, :action_details,:follow_up_required)

      </querytext>
</fullquery>

 
<fullquery name="insert_into_cs_action_info_map">      
      <querytext>
      insert into ec_cs_action_info_used_map
    (action_id, info_used)
    values
    (:action_id, :info_used)
    
      </querytext>
</fullquery>

 
</queryset>
