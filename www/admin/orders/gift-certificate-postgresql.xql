<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="gift_certificate_select">      
      <querytext>

select c.*, i.first_names || ' ' || i.last_name as issuer, i.user_id as issuer_user_id, p.first_names || ' ' || p.last_name as purchaser, p.user_id as purchaser_user_id, gift_certificate_amount_left(c.gift_certificate_id) as amount_left, case when current_timestamp-expires >= 0 then 't' else 'f' end as expired_p, v.first_names as voided_by_first_names, v.last_name as voided_by_last_name, o.first_names || ' ' || o.last_name as owned_by
from ec_gift_certificates c
    LEFT JOIN cc_users i on (c.issued_by=i.user_id)
    LEFT JOIN cc_users p on (c.purchased_by=p.user_id)
    LEFT JOIN cc_users v on (c.voided_by=v.user_id)
    LEFT JOIN cc_users o on (c.user_id=o.user_id)
where c.gift_certificate_id=:gift_certificate_id

      </querytext>
</fullquery>

 
</queryset>
