<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="select_one">      
      <querytext>
      
    select 1
      
     where to_date('$start_date(date)','YYYY-MM-DD HH24:MI:SS')  > to_date('$end_date(date)', 'YYYY-MM-DD HH24:MI:SS')
    
      </querytext>
</fullquery>

 
</queryset>
