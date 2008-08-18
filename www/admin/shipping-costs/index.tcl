#  www/[ec_url_concat [ec_url] /admin]/shipping-costs/index.tcl
ad_page_contract {

  @author
  @creation-date
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com) and Walter McGinnis (wtem@olywa.net)
} {
}

ad_require_permission [ad_conn package_id] admin

set title "Shipping Costs"
set context [list $title]

# for audit table
set table_names_and_id_column [list ec_admin_settings ec_admin_settings_audit  admin_setting_id ]

db_1row get_shipping_costs "select base_shipping_cost, default_shipping_per_item, weight_shipping_cost, add_exp_base_shipping_cost, add_exp_amount_per_item, add_exp_amount_by_weight
from ec_admin_settings"

set shipping_costs_html "[ec_shipping_cost_summary $base_shipping_cost $default_shipping_per_item $weight_shipping_cost $add_exp_base_shipping_cost $add_exp_amount_per_item $add_exp_amount_by_weight]"

set currency [parameter::get -package_id [ec_id] -parameter Currency -default "USD"]
set weight_unit [parameter::get -package_id [ec_id] -parameter WeightUnits -default "lbs"]
set audit_url_html "[ec_url_concat [ec_url] /admin]/audit-tables?[export_url_vars table_names_and_id_column]"
