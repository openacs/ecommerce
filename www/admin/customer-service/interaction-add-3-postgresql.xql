<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="get_interaction_date">      
      <querytext>
      select to_char(interaction_date, 'YYYY-MM-DD HH24:MI:SS') as open_date_str from ec_customer_serv_interactions where interaction_id=:interaction_id
      </querytext>
</fullquery>

 
<partialquery name="date_string_sql">
      <querytext>

      to_timestamp(:open_date_str,'YYYY-MM-DD HH24:MI:SS')

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
