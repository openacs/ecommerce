<?xml version="1.0"?>
<queryset>


<fullquery name="get_actions_by_cs_rep_sql">
      <querytext>

      select customer_service_rep, first_names, last_name, count(*) as n_interactions
      from ec_customer_serv_interactions, cc_users
      where ec_customer_serv_interactions.customer_service_rep=cc_users.user_id
      group by customer_service_rep, first_names, last_name
      order by count(*) desc

      </querytext>
</fullquery>

<fullquery name="get_issue_type_list">      
      <querytext>

      select picklist_item from ec_picklist_items where picklist_name='issue_type' order by sort_key

      </querytext>
</fullquery>

 
<fullquery name="get_important_info_list">      
      <querytext>

      select picklist_item from ec_picklist_items where picklist_name='info_used' order by sort_key

      </querytext>
</fullquery>

 
</queryset>
