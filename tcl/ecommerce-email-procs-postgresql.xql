<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="email_info_select">      
      <querytext>
      
	select u.email,
               to_char(confirmed_date,'MM/DD/YY') as confirmed_date,
               shipping_address, u.user_id
          from ec_orders, cc_users u
	 where ec_orders.user_id = u.user_id
	   and order_id = :order_id
    
      </querytext>
</fullquery>

 
<fullquery name="email_log_insert">      
      <querytext>
      
	    insert into ec_automatic_email_log
	    (user_identification_id, email_template_id, order_id, date_sent)
	    values
	    (:user_identification_id, 1, :order_id, current_timestamp)
	
      </querytext>
</fullquery>

 
<fullquery name="email_log_insert">      
      <querytext>
      
	  insert into ec_automatic_email_log
	  (user_identification_id, email_template_id, order_id, date_sent)
	  values
	  (:user_identification_id, 3, :order_id, current_timestamp)
      
      </querytext>
</fullquery>

 
<fullquery name="email_log_insert">      
      <querytext>
      
	  insert into ec_automatic_email_log
	  (user_identification_id, email_template_id, order_id, date_sent)
	  values
	  (:user_identification_id, 3, :order_id, current_timestamp)
      
      </querytext>
</fullquery>

 
<fullquery name="email_log_insert">      
      <querytext>
      
	  insert into ec_automatic_email_log
	  (user_identification_id, email_template_id, order_id, date_sent)
	  values
	  (:user_identification_id, 3, :order_id, current_timestamp)
      
      </querytext>
</fullquery>

 
<fullquery name="email_log_insert">      
      <querytext>
      
	  insert into ec_automatic_email_log
	  (user_identification_id, email_template_id, order_id, date_sent)
	  values
	  (:user_identification_id, 3, :order_id, current_timestamp)
      
      </querytext>
</fullquery>

 
<fullquery name="email_log_insert">      
      <querytext>
      
	  insert into ec_automatic_email_log
	  (user_identification_id, email_template_id, order_id, date_sent)
	  values
	  (:user_identification_id, 3, :order_id, current_timestamp)
      
      </querytext>
</fullquery>

 
</queryset>
