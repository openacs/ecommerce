<?xml version="1.0"?>
<queryset>

<fullquery name="get_issue_types">      
      <querytext>
      select issue_type from ec_cs_issue_type_map where issue_id=:issue_id
      </querytext>
</fullquery>

 
<fullquery name="get_user_name">      
      <querytext>
      select first_names || ' ' || last_name from cc_users where user_id=:customer_service_rep
      </querytext>
</fullquery>

 
</queryset>
