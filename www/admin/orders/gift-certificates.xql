<?xml version="1.0"?>
<queryset>

<fullquery name="gift_certificates_select">      
      <querytext>
      select g.gift_certificate_id, g.issue_date, g.gift_certificate_state, g.recipient_email, g.purchased_by, g.amount, u.first_names, u.last_name
from ec_gift_certificates g, cc_users u
where g.purchased_by=u.user_id
$issue_date_query_bit $gift_certificate_state_query_bit
order by $order_by_clause

      </querytext>
</fullquery>

 
</queryset>
