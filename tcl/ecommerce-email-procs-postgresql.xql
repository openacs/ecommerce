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

 
<fullquery name="email_log_insert_1">
      <querytext>

            insert into ec_automatic_email_log
            (user_identification_id, email_template_id, order_id, date_sent)
            values
            (:user_identification_id, 1, :order_id, current_timestamp)

      </querytext>
</fullquery>


<fullquery name="email_log_insert_2">
      <querytext>

          insert into ec_automatic_email_log
          (user_identification_id, email_template_id, order_id, shipment_id, date_sent)
          values
          (:user_identification_id, 2, :order_id, :shipment_id, current_timestamp)

      </querytext>
</fullquery>


<fullquery name="email_log_insert_3">
      <querytext>

          insert into ec_automatic_email_log
          (user_identification_id, email_template_id, order_id, date_sent)
          values
          (:user_identification_id, 3, :order_id, current_timestamp)

      </querytext>
</fullquery>


<fullquery name="email_log_insert_4">
      <querytext>

          insert into ec_automatic_email_log
          (user_identification_id, email_template_id, gift_certificate_id, date_sent)
          values
          (:user_identification_id, 4, :gift_certificate_id, current_timestamp)


      </querytext>
</fullquery>


<fullquery name="email_log_insert_5">
      <querytext>

          insert into ec_automatic_email_log
          (user_identification_id, email_template_id, gift_certificate_id, date_sent)
          values
          (:user_identification_id, 5, :gift_certificate_id, current_timestamp)

      </querytext>
</fullquery>


<fullquery name="email_log_insert_6">
      <querytext>

          insert into ec_automatic_email_log
          (user_identification_id, email_template_id, gift_certificate_id, date_sent)
          values
          (:user_identification_id, 6, :gift_certificate_id, current_timestamp)

      </querytext>
</fullquery>
 

<fullquery name="user_identification_id_seq">
      <querytext>

	select ec_user_ident_id_seq.nextval 

      </querytext>
</fullquery>

</queryset>
