<?xml version="1.0"?>

<queryset>
  <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

  <partialquery name="include_resolved_date">
    <querytext>
      and resolved_date is null
    </querytext>
  </partialquery>

  <fullquery name="problems_select">      
    <querytext>
      select l.*, p.first_names || ' ' || p.last_name as user_name
      from ec_problems_log l, persons p
      where l.resolved_by = p.person_id(+)
      $sql_clause
      order by problem_date asc  
    </querytext>
  </fullquery>
  
</queryset>
