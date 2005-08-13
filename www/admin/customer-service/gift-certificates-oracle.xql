<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="get_pretty_price">      
      <querytext>
      select ec_gift_certificate_balance(:user_id) from dual
      </querytext>
</fullquery>

<fullquery name="get_gift_certificates_for_user">
    <querytext>
        select c.*, 
               i.first_names || ' ' || i.last_name as issuer, 
               i.user_id as issuer_user_id, 
               p.first_names || ' ' || p.last_name as purchaser, 
               p.user_id as purchaser_user_id, 
               gift_certificate_amount_left(c.gift_certificate_id) as amount_left, 
               decode(sign(sysdate-expires),1,'t',0,'t','f') as expired_p, 
               v.first_names as voided_by_first_names, v.last_name as voided_by_last_name
               decode(amount_left,0,'t','f') as amount_left_is_zero,
               decode(gift_certificate_state,'void','t','f') as state_is_void
        from ec_gift_certificates c, 
             cc_users i, 
             cc_users p, 
             cc_users v
        where c.issued_by=i.user_id(+)
        and c.purchased_by=p.user_id(+)
        and c.voided_by=v.user_id(+)
        and c.user_id=:user_id
        order by expired_p, amount_left_is_zero, state_is_void, gift_certificate_id
    </querytext>  
</queryset>
