<?xml version="1.0"?>

<queryset>
  <rdbms>
    <type>oracle</type>
    <version>8.1.6</version>
  </rdbms>

  <fullquery name="get_product_and_user_info">      
    <querytext>
      select product_name, ec_product_comment_id_sequence.nextval as comment_id, user_email, to_char(sysdate,'Day Month DD, YYYY') as current_date
      from ec_products, (select email as user_email
          from cc_users
          where user_id = :user_id)
      where product_id=:product_id
    </querytext>
  </fullquery>

</queryset>
