<?xml version="1.0"?>

<queryset>
  <rdbms>
    <type>postgresql</type>
    <version>7.1</version>
  </rdbms>

  <fullquery name="ec_url_mem.ec_mountpoint">      
    <querytext>
      select site_node__url(s.node_id)
      from site_nodes s, apm_packages a
      where s.object_id = a.package_id
      and a.package_key = 'ecommerce'
    </querytext>
  </fullquery>

  <fullquery name="ec_package_url_lookup_mem.ec_mountpoint">      
    <querytext>
      select site_node__url(s.node_id)
      from site_nodes s, apm_packages a
      where s.object_id = a.package_id
      and a.package_key = '$package_key'
    </querytext>
  </fullquery>

  <fullquery name="ec_customer_comments.product_comment_info_select">      
    <querytext>
      select c.one_line_summary,
      c.rating,
      c.user_comment,
      to_char(c.last_modified,'Day Month DD, YYYY') as last_modified_pretty,
      u.email,
      u.user_id
      from ec_product_comments c,
      cc_users u
      where c.user_id = u.user_id
      and c.product_id = :product_id
      $end_of_comment_query
    </querytext>
  </fullquery>

  <fullquery name="ec_add_to_cart_link.get_product_info_1">      
    <querytext>
      select case when current_timestamp > available_date  then 1 when current_timestamp-available_date is NULL then 1 else 0 end as available_p,
      color_list, size_list, style_list, no_shipping_avail_p
      from ec_products
      where product_id = :product_id
    </querytext>
  </fullquery>

  <fullquery name="ec_add_to_cart_link.available_date_select">      
    <querytext>
      select to_char(available_date,'Month DD, YYYY') as available_date
      from ec_products
      where product_id = :product_id
    </querytext>
  </fullquery>

  <fullquery name="ec_create_new_session_if_necessary.insert_user_session_sql">      
    <querytext>
      insert into ec_user_sessions
      (user_session_id, ip_address, start_time, http_user_agent)
      values
      (:user_session_id, :ip_address, current_timestamp, :http_user_agent)
    </querytext>
  </fullquery>

  <fullquery name="ec_price_line.get_regular_approvalrequired_price">      
    <querytext>
      select min(case when ucp.price is null then p.price 
          when p.price < ucp.price then p.price 
          else ucp.price end) as regular_price, ucp.user_class_name 
      from ec_products p left join (select uc.product_id, uc.price, c.user_class_name 
          from ec_product_user_class_prices uc, ec_user_classes c, ec_user_class_user_map m 
          where uc.user_class_id = c.user_class_id 
          and uc.product_id = :product_id
          and uc.user_class_id = m.user_class_id
          and m.user_id = :user_id 
          and m.user_class_approved_p = 't' 
          order by uc.price
          limit 1) as ucp using (product_id) 
      where p.product_id = :product_id 
      group by p.product_id, ucp.user_class_name
    </querytext>
  </fullquery>

  <fullquery name="ec_price_line.get_regular_no_approval_required_price">      
    <querytext>
      select min(case when ucp.price is null then p.price 
          when p.price < ucp.price then p.price 
          else ucp.price end) as regular_price, ucp.user_class_name 
      from ec_products p left join (select uc.product_id, uc.price, c.user_class_name 
          from ec_product_user_class_prices uc, ec_user_classes c, ec_user_class_user_map m 
          where uc.user_class_id = c.user_class_id 
          and uc.product_id = :product_id
          and uc.user_class_id = m.user_class_id
          and m.user_id = :user_id 
          and (m.user_class_approved_p is null 
          or m.user_class_approved_p = 't')
          order by uc.price
          limit 1) as ucp using (product_id) 
      where p.product_id = :product_id 
      group by p.product_id, ucp.user_class_name
    </querytext>
  </fullquery>

</queryset>
