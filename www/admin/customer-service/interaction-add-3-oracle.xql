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


<partialquery name="date_string_sql">
      <querytext>

      to_date(:open_date_str,'YYYY-MM-DD HH24:MI:SS')

      </querytext>
</partialquery>


<partialquery name="customer_service_rep_bit_null_sql">
      <querytext>

      null
                                                                                      </querytext>
</partialquery>

                                                                                
<partialquery name="close_date_null_sql">
      <querytext>
      
      null                                                                      
      </querytext>
</partialquery>


<fullquery name="insert_new_ec_cs_issue">
      <querytext>
      insert into ec_customer_service_issues
      (issue_id, user_identification_id, order_id, open_date, close_date, closed_by)
      values
      (:issue_id, :uiid_to_insert, :order_id, $date_string, $close_date, $customer_service_rep_bit)

      </querytext>
</fullquery>

 
</queryset>
