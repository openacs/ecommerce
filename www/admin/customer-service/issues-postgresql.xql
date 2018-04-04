<?xml version="1.0"?>
<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>


<partialquery name="last_24">
      <querytext>
	and now()-i.open_date <= timespan_days(1)
      </querytext>
</partialquery>


<partialquery name="last_week">
      <querytext>
	and now()-i.open_date <= timespan_days(7)
      </querytext>
</partialquery>

<partialquery name="last_month">
      <querytext>
	and now()-i.open_date <= '1 month'::interval
      </querytext>
</partialquery>

<fullquery name="uncategorized">
      <querytext>

    select i.issue_id, u.user_id, u.first_names as users_first_names,
    u.last_name as users_last_name, id.user_identification_id, i.order_id,
    to_char(open_date,'YYYY-MM-DD HH24:MI:SS') as full_open_date,
    to_char(close_date,'YYYY-MM-DD HH24:MI:SS') as full_close_date
    from ec_customer_service_issues i
	JOIN ec_user_identification id using (user_identification_id)
	LEFT JOIN cc_users u on (id.user_id = u.user_id)
    where 0 = (select count(*) from ec_cs_issue_type_map m where m.issue_id=i.issue_id)
    $open_date_query_bit $status_query_bit
    order by i.issue_id desc

      </querytext>
</fullquery>

<fullquery name="all_others">
      <querytext>

    select i.issue_id, u.user_id, u.first_names as users_first_names,
    u.last_name as users_last_name, id.user_identification_id, i.order_id,
    to_char(open_date,'YYYY-MM-DD HH24:MI:SS') as full_open_date,
    to_char(close_date,'YYYY-MM-DD HH24:MI:SS') as full_close_date,
    m.issue_type
    from ec_cs_issue_type_map m, ec_customer_service_issues i
	JOIN ec_user_identification id using (user_identification_id)
	LEFT JOIN cc_users u on (id.user_id = u.user_id)
	-- gilbertw
	-- removed this and used a normal where constraint so I dont have to
	-- worry about setting up the correct and/where statement for the
	-- dynamic queries
	-- JOIN ec_cs_issue_type_map m on (i.issue_id = m.issue_id)
    where i.issue_id = m.issue_id
    $open_date_query_bit $status_query_bit
    $issue_type_query_bit
    order by $order_by_sql

      </querytext>
</fullquery>

<fullquery name="default_query">
      <querytext>     

    select i.issue_id, u.user_id, u.first_names as users_first_names,
    u.last_name as users_last_name, id.user_identification_id, i.order_id,
    to_char(open_date,'YYYY-MM-DD HH24:MI:SS') as full_open_date,
    to_char(close_date,'YYYY-MM-DD HH24:MI:SS') as full_close_date,
    m.issue_type
    from ec_customer_service_issues i
	JOIN ec_user_identification id using (user_identification_id)
	LEFT JOIN cc_users u on (id.user_id = u.user_id)
	JOIN ec_cs_issue_type_map m on (i.issue_id = m.issue_id)
    where m.issue_type=:view_issue_type
    $open_date_query_bit $status_query_bit
    order by $order_by_sql

      </querytext>
</fullquery>

 
</queryset>
