<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="get_user_info">      
      <querytext>
      select i.user_identification_id, i.order_id, i.closed_by, i.deleted_p, i.open_date, i.close_date, to_char(i.open_date,'YYYY-MM-DD HH24:MI:SS') as full_open_date, to_char(i.close_date,'YYYY-MM-DD HH24:MI:SS') as full_close_date, u.first_names || ' ' || u.last_name as closed_rep_name
from ec_customer_service_issues i, cc_users u
where i.closed_by=u.user_id(+)
and issue_id=:issue_id
      </querytext>
</fullquery>

 
</queryset>
