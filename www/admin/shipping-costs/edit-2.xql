<?xml version="1.0"?>
<queryset>

<fullquery name="update_shipping_cost_settings">      
      <querytext>
      update ec_admin_settings
set base_shipping_cost = :base_shipping_cost,
default_shipping_per_item = :default_shipping_per_item,
weight_shipping_cost = :weight_shipping_cost,
add_exp_base_shipping_cost = :add_exp_base_shipping_cost,
add_exp_amount_per_item = :add_exp_amount_per_item,
add_exp_amount_by_weight = :add_exp_amount_by_weight
      </querytext>
</fullquery>

 
</queryset>
