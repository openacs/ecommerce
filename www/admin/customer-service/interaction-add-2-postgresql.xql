<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="select_time">      
      <querytext>
      select to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS') 
      </querytext>
</fullquery>

 
<fullquery name="get_interaction_id">      
      <querytext>
      select ec_action_id_sequence.nextval 
      </querytext>
</fullquery>

 
</queryset>
