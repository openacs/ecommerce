<?xml version="1.0"?>
<queryset>

<fullquery name="get_open_issues">      
      <querytext>
      select count(*) 
from ec_customer_service_issues issues, ec_user_identification id
where issues.user_identification_id = id.user_identification_id
and close_date is NULL 
and deleted_p = 'f'
and 0 = (select count(*) from ec_cs_issue_type_map map where map.issue_id=issues.issue_id)
      </querytext>
</fullquery>

 
<fullquery name="get_issue_type_list">      
      <querytext>
      select picklist_item from ec_picklist_items where picklist_name='issue_type' order by sort_key
      </querytext>
</fullquery>

 
<fullquery name="get_open_issues_of_type">      
      <querytext>
      select count(*) 
from ec_customer_service_issues issues, ec_user_identification id
where issues.user_identification_id = id.user_identification_id
and close_date is NULL 
and deleted_p = 'f'
and 1 <= (select count(*) from ec_cs_issue_type_map map where map.issue_id=issues.issue_id and map.issue_type=:issue_type)
      </querytext>
</fullquery>

 
<fullquery name="get_num_open_issues_2">      
      <querytext>
      select count(*) 
from ec_customer_service_issues issues, ec_user_identification id
where issues.user_identification_id = id.user_identification_id
and close_date is NULL 
and deleted_p = 'f'
$last_bit_of_query
      </querytext>
</fullquery>

 
</queryset>
