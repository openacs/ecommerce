<?xml version="1.0"?>
<queryset>

<fullquery name="get_picklist_items">      
      <querytext>
      
  select picklist_item
    from ec_picklist_items
   where picklist_name='info_used'
order by sort_key

      </querytext>
</fullquery>


<fullquery name="get_customer_service_data_sql">
      <querytext>

select i.customer_service_rep as rep, u.first_names as rep_first_names, u.last_name as rep_last_name
    from ec_customer_serv_interactions i, cc_users u
   where i.customer_service_rep=u.user_id
group by i.customer_service_rep, u.first_names, u.last_name
order by u.last_name, u.first_names

      </querytext>
</fullquery>



 
</queryset>
