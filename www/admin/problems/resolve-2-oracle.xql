<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="unused">      
      <querytext>
      update ec_problems_log set resolved_by=:user_id, resolved_date=sysdate where problem_id = :problem_id
      </querytext>
</fullquery>

 
</queryset>
