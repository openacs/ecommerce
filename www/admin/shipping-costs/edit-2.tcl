#  www/[ec_url_concat [ec_url] /admin]/shipping-costs/edit-2.tcl
ad_page_contract {
    @param base_shipping_cost
    @param default_shipping_per_item
    @param weight_shipping_cost
    @param add_exp_base_shipping_cost
    @param add_exp_amount_per_item
    @param add_exp_amount_by_weight

  @author
  @creation-date
  @cvs-id edit-2.tcl,v 3.1.6.3 2000/07/21 03:57:04 ron Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} { 
    base_shipping_cost
    default_shipping_per_item
    weight_shipping_cost
    add_exp_base_shipping_cost
    add_exp_amount_per_item
    add_exp_amount_by_weight
}

ad_require_permission [ad_conn package_id] admin

db_dml update_shipping_cost_settings "update ec_admin_settings
set base_shipping_cost = :base_shipping_cost,
default_shipping_per_item = :default_shipping_per_item,
weight_shipping_cost = :weight_shipping_cost,
add_exp_base_shipping_cost = :add_exp_base_shipping_cost,
add_exp_amount_per_item = :add_exp_amount_per_item,
add_exp_amount_by_weight = :add_exp_amount_by_weight"
db_release_unused_handles

ad_returnredirect "index.tcl"

