<?xml version="1.0"?>
<queryset>

  <fullquery name="order_select">
    <querytext>
      select o.order_state, o.creditcard_id, o.confirmed_date, o.cs_comments,
         o.shipping_method, o.shipping_address, o.in_basket_date,
         o.authorized_date, o.shipping_charged, o.voided_by, o.voided_date,
         o.reason_for_void, u.user_id, u.first_names, u.last_name, c.billing_address
      from ec_orders o
      left join cc_users u using (user_id)
      left join ec_creditcards c using (creditcard_id)
      where order_id=:order_id
    </querytext>
  </fullquery>
  
</queryset>
