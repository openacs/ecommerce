<?xml version="1.0"?>
<queryset>

  <fullquery name="problem_count">      
    <querytext>
      select count(*) 
      from ec_problems_log
    </querytext>
  </fullquery>
  
  <fullquery name="unresolved_count">      
    <querytext>
      select count(*) from 
      ec_problems_log 
      where resolved_date is null
    </querytext>
  </fullquery>

</queryset>