<?xml version="1.0"?>

<queryset>
  <rdbms>
    <type>postgresql</type>
    <version>7.1</version>
  </rdbms>

  <fullquery name="ec_customer_service_simple_issue.get_ec_issue_seq">      
    <querytext>
      select ec_issue_id_sequence.nextval 
    </querytext>
  </fullquery>
  
  <fullquery name="ec_customer_service_simple_issue.customer_service_interaction_insert">      
    <querytext>
      insert into ec_customer_serv_interactions
      (interaction_id, customer_service_rep, user_identification_id, interaction_date, interaction_originator, interaction_type, interaction_headers)
      values
      (:interaction_id, :customer_service_rep, :user_identification_id, current_timestamp, :interaction_originator, :interaction_type, :interaction_headers)
    </querytext>
  </fullquery>
  
  <fullquery name="ec_customer_service_simple_issue.customer_service_issue_insert">      
    <querytext>
      insert into ec_customer_service_issues
      (issue_id, user_identification_id, order_id, open_date, close_date, closed_by, gift_certificate_id)
      values
      (:issue_id, :user_identification_id, :order_id, current_timestamp, current_timestamp, :customer_service_rep, :gift_certificate_id)
    </querytext>
  </fullquery>
  
</queryset>
