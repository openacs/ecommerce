<?xml version="1.0"?>

<queryset>
  <rdbms>
    <type>oracle</type>
    <version>8.1.6</version>
  </rdbms>

  <fullquery name="ec_email_new_order.email_info_select">      
    <querytext>
      select u.email,
      to_char(confirmed_date,'MM/DD/YY') as confirmed_date,
      shipping_address, u.user_id
      from ec_orders, cc_users u
      where ec_orders.user_id = u.user_id
      and order_id = :order_id
    </querytext>
  </fullquery>
  
  <fullquery name="ec_email_new_order.email_log_insert_1">      
    <querytext>
      insert into ec_automatic_email_log
      (user_identification_id, email_template_id, order_id, date_sent)
      values
      (:user_identification_id, 1, :order_id, sysdate)
    </querytext>
  </fullquery>

  <fullquery name="ec_email_order_shipped.email_log_insert_2">      
    <querytext>
      insert into ec_automatic_email_log
      (user_identification_id, email_template_id, order_id, shipment_id, date_sent)
      values
      (:user_identification_id, 2, :order_id, :shipment_id, sysdate)
    </querytext>
  </fullquery>
  
  <fullquery name="ec_email_delayed_credit_denied.email_log_insert_3">      
    <querytext>
      insert into ec_automatic_email_log
      (user_identification_id, email_template_id, order_id, date_sent)
      values
      (:user_identification_id, 3, :order_id, sysdate)
    </querytext>
  </fullquery>

  <fullquery name="ec_email_new_gift_certificate_order.email_log_insert_4">      
    <querytext>
      insert into ec_automatic_email_log
      (user_identification_id, email_template_id, gift_certificate_id, date_sent)
      values
      (:user_identification_id, 4, :gift_certificate_id, sysdate)
    </querytext>
  </fullquery>

  <fullquery name="ec_email_gift_certificate_recipient.email_log_insert_5">      
    <querytext>
      insert into ec_automatic_email_log
      (user_identification_id, email_template_id, gift_certificate_id, date_sent)
      values
      (:user_identification_id, 5, :gift_certificate_id, sysdate)
    </querytext>
  </fullquery>

  <fullquery name="ec_email_gift_certificate_order_failure.email_log_insert_6">      
    <querytext>
      insert into ec_automatic_email_log
      (user_identification_id, email_template_id, gift_certificate_id, date_sent)
      values
      (:user_identification_id, 6, :gift_certificate_id, sysdate)
    </querytext>
  </fullquery>

</queryset>
