<?xml version="1.0"?>

<queryset>
  <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

  <partialquery name="bought_product">
    <querytext>
      select unique u.user_id as user_id, first_names, last_name, email 
      from cc_users u, ec_items i, ec_orders o, ec_products p 
      where i.order_id = o.order_id 
      and o.user_id = u.user_id
      and i.product_id = p.product_id
      and p.sku = :product_sku
    </querytext>
  </partialquery>

  <partialquery name="viewed_product">
    <querytext>
      select unique u.user_id as user_id, first_names, last_name, email 
      from cc_users u, ec_user_session_info ui, ec_user_sessions us, ec_products p 
      where us.user_session_id=ui.user_session_id and us.user_id=u.user_id and ui.product_id=p.product_ud and p.sku=:viewed_product_sku
    </querytext>
  </partialquery>

  <partialquery name="viewed_category">
    <querytext>
      select unique u.user_id as user_id, first_names, last_name, email 
      from cc_users u, ec_user_session_info ui, ec_user_sessions us 
      where us.user_session_id=ui.user_session_id and us.user_id=u.user_id and ui.category_id=:category_id
    </querytext>
  </partialquery>

  <fullquery name="insert_record_for_gift_certificates">      
    <querytext>
      insert into ec_gift_certificates
      (gift_certificate_id, user_id, amount, 
      expires, 
      issue_date, issued_by, gift_certificate_state, 
      last_modified, last_modifying_user, modified_ip_address)
      values
      (ec_gift_cert_id_sequence.nextval, :user_id, :amount, 
      $expires_to_insert, 
      sysdate, :customer_service_rep, 'authorized', 
      sysdate, :customer_service_rep, '[ns_conn peeraddr]')
    </querytext>
  </fullquery>
  
  <fullquery name="insert_log_for_spam">      
    <querytext>
      insert into ec_spam_log
      (spam_id, spam_date, spam_text, mailing_list_category_id, 
      mailing_list_subcategory_id, mailing_list_subsubcategory_id, 
      user_class_id, product_id, 
      last_visit_start_date, last_visit_end_date)
      values
      (:spam_id, sysdate, :message, :mailing_list_category_id, 
      :mailing_list_subcategory_id, :mailing_list_subsubcategory_id, 
      :user_class_id, :product_id, 
      to_date(:start,'YYYY-MM-DD HH24:MI:SS'), 
      to_date(:end,'YYYY-MM-DD HH24:MI:SS'))
    </querytext>
  </fullquery>
  
</queryset>
