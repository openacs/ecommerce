<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="ec_url_mem.ec_mountpoint">      
      <querytext>
      
            select site_node__url(s.node_id)
              from site_nodes s, apm_packages a
             where s.object_id = a.package_id
               and a.package_key = 'ecommerce'
        
      </querytext>
</fullquery>

 
<fullquery name="ec_url_lookup_mem.ec_mountpoint">      
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
 	       to_char(c.last_modified,'Day Month DD, YYYY') last_modified_pretty,
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

	select case when current_timestamp-available_date > 0 then 1 when current_timestamp-available_date is NULL then 1 else 0 end as available_p,
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

 
<fullquery name="ec_create_new_session_if_necessary.insert_user_session">      
      <querytext>
      
                    insert into ec_user_sessions
                    (user_session_id, ip_address, start_time, http_user_agent)
                    values
                    (:user_session_id, :ip_address, current_timestamp, :http_user_agent)
                
      </querytext>
</fullquery>

 
</queryset>
