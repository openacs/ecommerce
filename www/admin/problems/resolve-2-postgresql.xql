<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="unused">      
      <querytext>
      update ec_problems_log set resolved_by=:user_id, resolved_date=current_timestamp where problem_id = :problem_id
      </querytext>
</fullquery>

 
</queryset>
