<?xml version="1.0"?>

<queryset>

  <fullquery name="template_select_1">   
    <querytext>
      select subject as email_subject, message as email_body, issue_type_list
      from ec_email_templates
      where email_template_id = 1
    </querytext>
  </fullquery>

  <fullquery name="notification_select">      
    <querytext>
      select ep.email_on_purchase_list, ep.product_name
      from ec_items ei, ec_products ep
      where ei.product_id = ep.product_id
      and ei.order_id = :order_id
      group by ep.email_on_purchase_list, ep.product_name
    </querytext>
  </fullquery>

  <fullquery name="user_select">      
    <querytext>
      select u.email, u.user_id
      from ec_orders, cc_users u
      where ec_orders.user_id = u.user_id
      and order_id = :order_id
    </querytext>
  </fullquery>

  <fullquery name="template_select_3">      
    <querytext>
      select subject as email_subject, message as email_body, issue_type_list
      from ec_email_templates
      where email_template_id = 3
    </querytext>
  </fullquery>

  <fullquery name="shipment_select">      
    <querytext>
      select u.email, u.user_id, s.shipment_date, s.address_id, o.order_state, o.order_id
      from ec_orders o, cc_users u, ec_shipments s
      where o.user_id = u.user_id
      and o.order_id = s.order_id
      and s.shipment_id = :shipment_id
    </querytext>
  </fullquery>

  <fullquery name="item_summary_select">      
    <querytext>
      select p.product_name, p.one_line_description, p.product_id, i.price_charged, i.price_name, count(*) as quantity
      from ec_items i, ec_products p
      where i.product_id=p.product_id
      and i.shipment_id=:shipment_id
      group by p.product_name, p.one_line_description, p.product_id, i.price_charged, i.price_name
    </querytext>
  </fullquery>

  <fullquery name="template_select_2">      
    <querytext>
      select subject as email_subject, message as email_body, issue_type_list
      from ec_email_templates
      where email_template_id = 2
    </querytext>
  </fullquery>

  <fullquery name="gift_certificate_select">      
    <querytext>
      select g.purchased_by as user_id, u.email, g.recipient_email, g.amount
      from ec_gift_certificates g, cc_users u
      where g.purchased_by=u.user_id
      and g.gift_certificate_id=:gift_certificate_id
    </querytext>
  </fullquery>

  <fullquery name="template_select_4">      
    <querytext>
      select subject as email_subject, message as email_body, issue_type_list
      from ec_email_templates
      where email_template_id = 4
    </querytext>
  </fullquery>

  <fullquery name="gift_certificate_select_2">      
    <querytext>
      select g.purchased_by as user_id, u.email, g.recipient_email, g.amount, g.certificate_to, g.certificate_from, g.certificate_message
      from ec_gift_certificates g, cc_users u
      where g.purchased_by=u.user_id
      and g.gift_certificate_id=:gift_certificate_id
    </querytext>
  </fullquery>

  <fullquery name="template_select_6">      
    <querytext>
      select subject as email_subject, message as email_body, issue_type_list
      from ec_email_templates
      where email_template_id = 6
    </querytext>
  </fullquery>

  <fullquery name="gift_certificate_select_3">      
    <querytext>
      select g.recipient_email as email, g.amount, g.certificate_to, g.certificate_from, g.certificate_message, g.claim_check
      from ec_gift_certificates g
      where g.gift_certificate_id=:gift_certificate_id
    </querytext>
  </fullquery>

  <fullquery name="template_select_5">      
    <querytext>
      select subject as email_subject, message as email_body, issue_type_list from ec_email_templates where email_template_id=5
    </querytext>
  </fullquery>

  <fullquery name="user_id_select">      
    <querytext>
      select user_id
      from cc_users
      where email=lower(:email)
    </querytext>
  </fullquery>

  <fullquery name="user_identification_id_select">      
    <querytext>
      select user_identification_id from ec_user_identification where email=lower(:email)
    </querytext>
  </fullquery>

  <fullquery name="user_identification_id_insert">      
    <querytext>
      insert into ec_user_identification
      (user_identification_id, email)
      values
      (:user_identification_id, :trimmed_email)
    </querytext>
  </fullquery>

</queryset>
