<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="get_interaction_date">      
      <querytext>
      select to_char(interaction_date, 'YYYY-MM-DD HH24:MI:SS') as open_date_str from ec_customer_serv_interactions where interaction_id=:interaction_id
      </querytext>
</fullquery>

 
<fullquery name="get_new_interaction_id">      
      <querytext>
      select ec_interaction_id_sequence.nextval from dual
      </querytext>
</fullquery>

 
<fullquery name="get_new_interaction_id">      
      <querytext>
      select ec_interaction_id_sequence.nextval from dual
      </querytext>
</fullquery>

 
<fullquery name="get_uiid_to_insert_from_seq">      
      <querytext>
      select ec_user_ident_id_sequence.nextval from dual
      </querytext>
</fullquery>

 
</queryset>
