<?xml version="1.0"?>
<queryset>

<fullquery name="get_order_id">      
      <querytext>
      select order_id from ec_orders where user_session_id=:user_session_id and order_state='in_basket'
      </querytext>
</fullquery>

 
<fullquery name="get_count_cart">      
      <querytext>
      select count(*) from ec_items where order_id=:order_id
      </querytext>
</fullquery>

 
<fullquery name="get_order_owner">      
      <querytext>
      select user_id from ec_orders where order_id=:order_id
      </querytext>
</fullquery>

 
<fullquery name="get_address_id">      
      <querytext>
      select shipping_address from ec_orders where order_id=:order_id
      </querytext>
</fullquery>

 
<fullquery name="update_shipping_method">      
      <querytext>
      update ec_orders
set shipping_method=:shipping_method,
    tax_exempt_p=:tax_exempt_p
where order_id=:order_id
      </querytext>
</fullquery>

 
<fullquery name="get_list_user_classes">      
      <querytext>
      select user_class_id from ec_user_class_user_map where user_id=:user_id $additional_user_class_restriction
      </querytext>
</fullquery>

 
<fullquery name="get_shipping_per_item">      
      <querytext>
      select default_shipping_per_item, weight_shipping_cost from ec_admin_settings
      </querytext>
</fullquery>

 
<fullquery name="get_exp_amt_peritem">      
      <querytext>
      select add_exp_amount_per_item, add_exp_amount_by_weight from ec_admin_settings
      </querytext>
</fullquery>

 
<fullquery name="get_usps_abbrev">      
      <querytext>
      select usps_abbrev from ec_addresses where address_id=:address_id
      </querytext>
</fullquery>

 
<fullquery name="get_tax_rate">      
      <querytext>
      select tax_rate, shipping_p from ec_sales_tax_by_state where usps_abbrev=:usps_abbrev
      </querytext>
</fullquery>

 
<fullquery name="get_items_in_cart">      
      <querytext>
      FIX ME OUTER JOIN
select i.item_id, i.product_id, u.offer_code
from ec_items i,
(select * from ec_user_session_offer_codes usoc where usoc.user_session_id=:user_session_id) u
where i.product_id=u.product_id(+)
and i.order_id=:order_id
      </querytext>
</fullquery>

 
<fullquery name="update_ec_items">      
      <querytext>
      update ec_items set price_charged=round(:price_charged,2), price_name=:price_name, shipping_charged=round(:shipping_charged,2), price_tax_charged=round(:tax_charged,2), shipping_tax_charged=round(:shipping_tax,2) where item_id=:item_id
      </querytext>
</fullquery>

 
<fullquery name="get_base_ship_cost">      
      <querytext>
      select coalesce(base_shipping_cost,0) from ec_admin_settings
      </querytext>
</fullquery>

 
<fullquery name="get_exp_base_cost">      
      <querytext>
      select coalesce(add_exp_base_shipping_cost,0) from ec_admin_settings
      </querytext>
</fullquery>

 
<fullquery name="set_shipping_charges">      
      <querytext>
      update ec_orders set shipping_charged=round(:order_shipping_cost,2), shipping_tax_charged=round(:tax_on_order_shipping_cost,2) where order_id=:order_id
      </querytext>
</fullquery>

 
</queryset>
