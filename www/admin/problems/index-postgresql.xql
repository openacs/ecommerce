<?xml version="1.0"?>

<queryset>
  <rdbms><type>postgresql</type><version>7.1</version></rdbms>

  <partialquery name="include_resolved_date">
    <querytext>
      where resolved_date is null
    </querytext>
  </partialquery>
  
  <fullquery name="problems_select">      
    <querytext>
      select l.*, u.first_names || ' ' || u.last_name as user_name
      from ec_problems_log l
      left join cc_users u on (l.resolved_by = u.user_id)
      $sql_clause
      order by problem_date asc
    </querytext>
  </fullquery>

</queryset>
