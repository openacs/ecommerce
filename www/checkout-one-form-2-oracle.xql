<?xml version="1.0"?>

<queryset>
  <rdbms>
    <type>oracle</type>
    <version>8.1.6</version>
  </rdbms>

  <fullquery name="insert_error_failed_gc_claim">      
    <querytext>
      insert into ec_problems_log
      (problem_id, problem_date, problem_details)
      values
      (ec_problem_id_sequence.nextval, sysdate,:prob_details )
    </querytext>
  </fullquery>

  <fullquery name="update_ec_cert_set_user">      
    <querytext>
      update ec_gift_certificates set user_id=:user_id, claimed_date=sysdate where gift_certificate_id=:gift_certificate_id
    </querytext>
  </fullquery>

  <fullquery name="insert_other_claim_prob">      
    <querytext>
      insert into ec_problems_log
      (problem_id, problem_date, gift_certificate_id, problem_details)
      values
      (ec_problem_id_sequence.nextval, sysdate, :gift_certificate_id, :prob_details)
    </querytext>
  </fullquery>

  <fullquery name="get_items_in_cart">      
    <querytext>
            select i.item_id, i.product_id, u.offer_code
            from ec_items i, (select * 
            from ec_user_session_offer_codes usoc 
            where usoc.user_session_id = :user_session_id) u
            where i.product_id=u.product_id(+)
            and i.order_id=:order_id
    </querytext>
  </fullquery>

  <fullquery name="get_base_ship_cost">      
    <querytext>
      select nvl(base_shipping_cost,0) 
      from ec_admin_settings
    </querytext>
  </fullquery>

  <fullquery name="get_exp_base_cost">      
    <querytext>
      select nvl(add_exp_base_shipping_cost,0) 
      from ec_admin_settings
    </querytext>
  </fullquery>

  <fullquery name="get_shipping_tax">      
    <querytext>
      select ec_tax(0,:order_shipping_cost,:order_id) 
      from dual
    </querytext>
  </fullquery>

  <fullquery name="get_gc_balance">      
    <querytext>
      select ec_gift_certificate_balance(:user_id) 
      from dual
    </querytext>
  </fullquery>

</queryset>
