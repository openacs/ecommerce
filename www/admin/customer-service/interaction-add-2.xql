<?xml version="1.0"?>
<queryset>

<fullquery name="get_order_id">      
      <querytext>
      select order_id from ec_customer_service_issues where issue_id=:issue_id
      </querytext>
</fullquery>

 
<fullquery name="get_issue_type_list">      
      <querytext>
      select issue_type from ec_cs_issue_type_map where issue_id=:issue_id
      </querytext>
</fullquery>

 
<fullquery name="get_does_row_exist_p">      
      <querytext>
      select first_names as d_first_names, last_name as d_last_name, user_id as d_user_id from cc_users where upper(email) =:email 
      </querytext>
</fullquery>

 
</queryset>
