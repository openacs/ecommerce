<?xml version="1.0"?>

<queryset>
  <rdbms>
    <type>oracle</type>
    <version>8.1.6</version>
  </rdbms>

  <fullquery name="ec_url_mem.ec_mountpoint">      
    <querytext>
      select site_node.url(s.node_id)
      from site_nodes s, apm_packages a
      where s.object_id = a.package_id
      and a.package_key = 'ecommerce'
    </querytext>
  </fullquery>

  <fullquery name="ec_package_url_lookup_mem.ec_mountpoint">      
    <querytext>
      select site_node.url(s.node_id)
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
      select decode(sign(sysdate-available_date),1,1,null,1,0) as available_p,
      color_list, size_list, style_list, no_shipping_avail_p
      from ec_products
      where product_id = :product_id
    </querytext>
  </fullquery>

  <fullquery name="ec_add_to_cart_link.available_date_select">      
    <querytext>
      select to_char(available_date,'Month DD, YYYY') available_date
      from ec_products
      where product_id = :product_id
    </querytext>
  </fullquery>

  <fullquery name="ec_order_summary_for_customer.order_info_select">      
    <querytext>
      select eco.confirmed_date, eco.creditcard_id, eco.shipping_method,
      u.email,
      eca.line1, eca.line2, eca.city, eca.usps_abbrev, eca.zip_code, eca.country_code,
      eca.full_state_name, eca.attn, eca.phone, eca.phone_time
      from ec_orders eco,
      cc_users u,
      ec_addresses eca
      where eco.order_id = :order_id
      and eco.user_id = u.user_id(+)
      and eco.shipping_address = eca.address_id(+)
    </querytext>
  </fullquery>

  <fullquery name="ec_create_new_session_if_necessary.insert_user_session_sql">      
    <querytext>
      insert into ec_user_sessions
      (user_session_id, ip_address, start_time, http_user_agent)
      values
      (:user_session_id, :ip_address, sysdate, :http_user_agent)
    </querytext>
  </fullquery>

<fullquery name="ec_price_line.get_regular_approvalrequired_price">      
    <querytext>
      select min(decode(ucp.price,null,p.price,
      decode(sign(ucp.price-p.price),1,p.price,ucp.price))) as regular_price,
      ucp.user_class_name
      from ec_products p, (select * from (select uc.product_id, uc.price, c.user_class_name 
      from ec_product_user_class_prices uc, ec_user_classes c, 
      ec_user_class_user_map m 
      where uc.user_class_id = c.user_class_id 
      and uc.product_id = :product_id
      and uc.user_class_id = m.user_class_id
      and m.user_id = :user_id 
      and m.user_class_approved_p = 't' order by uc.price)
      where rownum=1) ucp
      where p.product_id = :product_id and ucp.product_id(+)=p.product_id
      group by p.product_id, p.price, ucp.user_class_name, ucp.price
    </querytext>
  </fullquery>

  <fullquery name="ec_price_line.get_regular_no_approval_required_price">      
    <querytext>
      select min(decode(ucp.price,null,p.price,
      decode(sign(ucp.price-p.price),1,p.price,ucp.price))) as regular_price,
      ucp.user_class_name
      from ec_products p, (select * from (select uc.product_id, uc.price, c.user_class_name 
      from ec_product_user_class_prices uc, ec_user_classes c, 
      ec_user_class_user_map m 
      where uc.user_class_id = c.user_class_id 
      and uc.product_id = :product_id
      and uc.user_class_id = m.user_class_id
      and m.user_id = :user_id 
      and (m.user_class_approved_p is null or m.user_class_approved_p = 't') order by uc.price)
      where rownum=1) ucp
      where p.product_id = :product_id and ucp.product_id(+)=p.product_id
      group by p.product_id, p.price, ucp.user_class_name, ucp.price
    </querytext>
  </fullquery>

</queryset>
