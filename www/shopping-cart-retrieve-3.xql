<?xml version="1.0"?>

<queryset>

  <fullquery name="get_order_exists_p">      
    <querytext>
      select count(*) 
      from ec_orders 
      where order_id=:order_id
    </querytext>
  </fullquery>

  <fullquery name="get_order_is_theirs">      
    <querytext>
      select count(*) 
      from ec_orders
      where order_id=:order_id
      and user_id=:user_id
    </querytext>
  </fullquery>

  <fullquery name="confirm_have_basket">      
    <querytext>
      select count(*) 
      from ec_orders
      where order_id=:order_id
      and order_state='in_basket' and saved_p='t'
    </querytext>
  </fullquery>

  <fullquery name="get_saved_shopping_cart">      
    <querytext>
      select p.product_name, p.one_line_description, p.product_id, i.color_choice, i.size_choice, i.style_choice, count(*) as quantity
      from ec_orders o, ec_items i, ec_products p
      where i.product_id=p.product_id
      and o.order_id=i.order_id
      and o.order_id=:order_id
      group by p.product_name, p.one_line_description, p.product_id, i.color_choice, i.size_choice, i.style_choice
    </querytext>
  </fullquery>

  <fullquery name="get_n_baskets">      
    <querytext>
      select count(*) 
      from ec_orders
      where order_state='in_basket'
      and user_session_id=:user_session_id
    </querytext>
  </fullquery>

  <fullquery name="update_ec_orders">      
    <querytext>
      update ec_orders set user_session_id=:user_session_id, saved_p='f' where order_id=:order_id
    </querytext>
  </fullquery>

  <fullquery name="get_special_offers">      
    <querytext>
      select o.offer_code, o.product_id
      from ec_user_sessions s, ec_user_session_offer_codes o, ec_sale_prices_current p
      where p.offer_code=o.offer_code
      and s.user_session_id=o.user_session_id
      and s.user_id=:user_id
      order by p.sale_price
    </querytext>
  </fullquery>

  <fullquery name="delete_previous_offer_codes">      
    <querytext>
      delete from ec_user_session_offer_codes
      where user_session_id=:user_session_id
    </querytext>
  </fullquery>

  <fullquery name="insert_session_offer">      
    <querytext>
      insert into ec_user_session_offer_codes
      (user_session_id, product_id, offer_code)
      values
      (:user_session_id, :temp_pd, :offprod)
    </querytext>
  </fullquery>

  <fullquery name="get_current_basket">      
    <querytext>
      select order_id 
      from ec_orders
      where user_session_id=:user_session_id
      and order_state='in_basket'
    </querytext>
  </fullquery>

  <fullquery name="update_order_basket_pr">      
    <querytext>
      update ec_items set order_id=:current_basket where order_id=:order_id
    </querytext>
  </fullquery>

  <fullquery name="get_product_offer_codes">      
    <querytext>
      select o.offer_code, o.product_id
      from ec_user_sessions s, ec_user_session_offer_codes o, ec_sale_prices_current p
      where p.offer_code=o.offer_code
      and s.user_session_id=o.user_session_id
      and s.user_id=:user_id
      order by p.sale_price
    </querytext>
  </fullquery>

  <fullquery name="delete_session_offer_codes">      
    <querytext>
      delete from ec_user_session_offer_codes
      where user_session_id=:user_session_id
    </querytext>
  </fullquery>

  <fullquery name="insert_session_offer">      
    <querytext>
      insert into ec_user_session_offer_codes
      (user_session_id, product_id, offer_code)
      values
      (:user_session_id, :temp_pd, :offprod)
    </querytext>
  </fullquery>

  <fullquery name="get_current_baskey">      
    <querytext>
      select order_id 
      from ec_orders
      where user_session_id=:user_session_id
      and order_state='in_basket'
    </querytext>
  </fullquery>

  <fullquery name="delete_current_items">      
    <querytext>
      delete from ec_items
      where order_id=:current_basket
    </querytext>
  </fullquery>

  <fullquery name="update_items">      
    <querytext>
      update ec_items set order_id=:current_basket where order_id=:order_id
    </querytext>
  </fullquery>

  <fullquery name="">      
    <querytext>
      select o.offer_code, o.product_id
      from ec_user_sessions s, ec_user_session_offer_codes o, ec_sale_prices_current p
      where p.offer_code=o.offer_code
      and s.user_session_id=o.user_session_id
      and s.user_id=:user_id
      order by p.sale_price
    </querytext>
  </fullquery>

  <fullquery name="delete_uc_offer_codes">      
    <querytext>
      delete from ec_user_session_offer_codes
      where user_session_id=:user_session_id
    </querytext>
  </fullquery>

  <fullquery name="insert_session_offer">      
    <querytext>
      insert into ec_user_session_offer_codes
      (user_session_id, product_id, offer_code)
      values
      (:user_session_id, :temp_pd, :offprod)
    </querytext>
  </fullquery>

  <fullquery name="delete_current_cart">      
    <querytext>
      delete from ec_items
      where order_id=:order_id
    </querytext>
  </fullquery>

  <fullquery name="delete_current_cart">      
    <querytext>
      delete from ec_items
      where order_id=:order_id
    </querytext>
  </fullquery>

</queryset>
