<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="gift_certificate_select">      
      <querytext>
      
select c.*, i.first_names || ' ' || i.last_name as issuer, i.user_id as issuer_user_id, p.first_names || ' ' || p.last_name as purchaser, p.user_id as purchaser_user_id, gift_certificate_amount_left(c.gift_certificate_id) as amount_left, decode(sign(sysdate-expires),1,'t',0,'t','f') as expired_p, v.first_names as voided_by_first_names, v.last_name as voided_by_last_name, o.first_names || ' ' || o.last_name as owned_by
from ec_gift_certificates c, cc_users i, cc_users p, cc_users v, cc_users o
where c.issued_by=i.user_id(+)
and c.purchased_by=p.user_id(+)
and c.voided_by=v.user_id(+)
and c.user_id=o.user_id(+)
and c.gift_certificate_id=:gift_certificate_id

      </querytext>
</fullquery>

 
</queryset>
