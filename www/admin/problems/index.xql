<?xml version="1.0"?>
<queryset>

<fullquery name="unused_all">      
      <querytext>
      select count(*) from ec_problems_log
      </querytext>
</fullquery>

 
<fullquery name="unused_null">      
      <querytext>
      select count(*) from ec_problems_log where resolved_date is null
      </querytext>
</fullquery>

 
<fullquery name="problems_select">      
      <querytext>

 select 
      l.*, 
      u.first_names || ' ' || u.last_name as user_name
 from ec_problems_log l
      LEFT JOIN cc_users u on (l.resolved_by = u.user_id)
      $sql_clause
 order by problem_date asc

      </querytext>
</fullquery>

 
</queryset>
