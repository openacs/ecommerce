<?xml version="1.0"?>
<queryset>

<fullquery name="refunds_select">      
      <querytext>
      select r.refund_id, r.refund_date, r.order_id, r.refund_amount, r.refunded_by, u.first_names, u.last_name, count(*) as n_items
from ec_refunds r, cc_users u, ec_items i
where r.refunded_by=u.user_id
and i.refund_id=r.refund_id
$refund_date_query_bit
group by r.refund_id, r.refund_date, r.order_id, r.refund_amount, r.refunded_by, u.first_names, u.last_name
order by $order_by_clause
      </querytext>
</fullquery>

 
</queryset>
