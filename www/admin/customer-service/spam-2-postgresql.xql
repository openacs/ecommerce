<?xml version="1.0"?>

<queryset>
  <rdbms><type>postgresql</type><version>7.1</version></rdbms>

  <partialquery name="bought_product">
    <querytext>
      select distinct u.user_id, first_names, last_name 
      from cc_users u, ec_items i, ec_orders o, ec_products p 
      where i.order_id=o.order_id and o.user_id=u.user_id and i.product_id = p.product_id and p.sku=:product_sku
    </querytext>
  </partialquery>

  <partialquery name="viewed_product">
    <querytext>
      select distinct u.user_id, first_names, last_name 
      from cc_users u, ec_user_session_info ui, ec_user_sessions us, ec_products p 
      where us.user_session_id=ui.user_session_id and us.user_id=u.user_id and ui.product_id = p.product_id and p.sku=:viewed_product_sku
    </querytext>
  </partialquery>

  <partialquery name="viewed_category">
    <querytext>
      select distinct u.user_id, first_names, last_name 
      from cc_users u, ec_user_session_info ui, ec_user_sessions us 
      where us.user_session_id=ui.user_session_id and us.user_id=u.user_id and ui.category_id=:category_id
    </querytext>
  </partialquery>

</queryset>