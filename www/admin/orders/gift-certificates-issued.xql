<?xml version="1.0"?>
<queryset>

<fullquery name="ec_customer_service_reps_select">      
      <querytext>
      
SELECT user_id as rep, first_names as rep_first_names, last_name as rep_last_name
FROM ec_customer_service_reps
ORDER BY last_name, first_names

      </querytext>
</fullquery>

 
<fullquery name="gift_certificates_select">      
      <querytext>
      
SELECT g.gift_certificate_id, g.issue_date, g.amount,
       g.issued_by, u.first_names, u.last_name,
       g.user_id as issued_to, r.first_names as issued_to_first_names, r.last_name as issued_to_last_name
from ec_gift_certificates_issued g, cc_users u, cc_users r
where g.issued_by=u.user_id and g.user_id=r.user_id
$issue_date_query_bit $rep_query_bit
order by $order_by_clause

      </querytext>
</fullquery>

 
</queryset>
