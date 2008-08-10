<?xml version="1.0"?>

<queryset>

  <fullquery name="insert_user_session_info">      
    <querytext>
      insert into ec_user_session_info 
      (user_session_id, product_id) 
      values 
      (:user_session_id, :product_id)
    </querytext>
  </fullquery>

  <fullquery name="get_offer_code_p">      
    <querytext>
      select count(*) 
      from ec_user_session_offer_codes
      where user_session_id=:user_session_id
      and product_id=:product_id
    </querytext>
  </fullquery>

  <fullquery name="inert_uc_offer_code">      
    <querytext>
      insert into ec_user_session_offer_codes
      (user_session_id, product_id, offer_code) 
      values 
      (:user_session_id, :product_id, :offer_code)
    </querytext>
  </fullquery>

  <fullquery name="update_ec_us_offers">      
    <querytext>
      update ec_user_session_offer_codes
      set offer_code=:offer_code
      where user_session_id=:user_session_id
      and product_id=:product_id
    </querytext>
  </fullquery>

  <fullquery name="get_offer_code">      
    <querytext>
      select offer_code
      from ec_user_session_offer_codes
      where user_session_id=:user_session_id
      and product_id=:product_id
    </querytext>
  </fullquery>

  <fullquery name="get_ec_product_info">      
    <querytext>
      select *
      from ec_products p
      left join ec_custom_product_field_values v on (p.product_id = v.product_id)
      where p.product_id = :product_id and  and p.present_p = 't'
    </querytext>
  </fullquery>

  <fullquery name="get_template">      
    <querytext>
      select template
      from ec_templates
      where template_id=:template_id
    </querytext>
  </fullquery>

  <fullquery name="get_template_list">      
    <querytext>
      select template
      from ec_templates t, ec_category_template_map ct, ec_category_product_map cp
      where t.template_id = ct.template_id
      and ct.category_id = cp.category_id
      and cp.product_id = :product_id
    </querytext>
  </fullquery>

  <fullquery name="get_template_finally">      
    <querytext>
      select template
      from ec_templates
      where template_id=(select default_template
          from ec_admin_settings)
    </querytext>
  </fullquery>

</queryset>
