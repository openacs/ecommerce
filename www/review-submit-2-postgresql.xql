<?xml version="1.0"?>

<queryset>
  <rdbms>
    <type>postgresql</type>
    <version>7.1</version>
  </rdbms>

  <fullquery name="get_product_and_user_info">      
    <querytext>
      select product_name, ec_product_comment_id_sequence.nextval as comment_id, user_email, to_char(current_timestamp,'Day Month DD, YYYY') as current_date
      from ec_products, (select email as user_email 
          from cc_users 
          where user_id = :user_id) as cc_emails
      where product_id=:product_id
    </querytext>
  </fullquery>

</queryset>
