<?xml version="1.0"?>
<queryset>

  <fullquery name="get_n_items">      
    <querytext>
      select count(*) 
      from ec_orders o, ec_items i
      where o.order_id=i.order_id
      and o.user_session_id=:user_session_id and o.order_state='in_basket'
    </querytext>
  </fullquery>
 
  <fullquery name="get_products_in_cart">      
    <querytext>
      select p.product_name, p.one_line_description, p.product_id, count(*) as quantity, u.offer_code, i.color_choice, i.size_choice, i.style_choice 
      from ec_orders o
      JOIN ec_items i on (o.order_id=i.order_id)
      JOIN ec_products p on (i.product_id=p.product_id)
      LEFT JOIN (select product_id, offer_code from ec_user_session_offer_codes usoc where usoc.user_session_id=:user_session_id) u 
        on (p.product_id=u.product_id)
      where o.user_session_id=:user_session_id and o.order_state='in_basket'
      group by p.product_name, p.one_line_description, p.product_id, u.offer_code, i.color_choice, i.size_choice, i.style_choice
    </querytext>
  </fullquery>
 
  <fullquery name="tax_states">      
    <querytext>
      select tax_rate, initcap(state_name) as state 
      from ec_sales_tax_by_state tax, us_states state 
      where state.abbrev = tax.usps_abbrev
    </querytext>
  </fullquery>

</queryset>
