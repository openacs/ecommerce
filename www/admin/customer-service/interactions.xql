<?xml version="1.0"?>
<queryset>

<fullquery name="get_interaction_type_list">      
      <querytext>
      select picklist_item from ec_picklist_items where picklist_name='interaction_type' order by sort_key
      </querytext>
</fullquery>


<fullquery name="get_rep_info_by_rep_sql">
      <querytext>

      select i.customer_service_rep as rep, u.first_names as rep_first_names, 
      u.last_name as rep_last_name 
      from ec_customer_serv_interactions i, cc_users u 
      where i.customer_service_rep=u.user_id
      group by i.customer_service_rep, u.first_names, u.last_name 
      order by u.last_name, u.first_names

      </querytext>
</fullquery>

 
</queryset>
