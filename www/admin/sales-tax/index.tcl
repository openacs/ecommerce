#  www/[ec_url_concat [ec_url] /admin]/sales-tax/index.tcl
ad_page_contract {

  @author
  @creation-date
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
}

ad_require_permission [ad_conn package_id] admin

set title "Sales Tax"
set context [list $title]

# for audit table
set table_names_and_id_column [list ec_sales_tax_by_state ec_sales_tax_by_state_audit usps_abbrev]

set sales_taxes_html ""
set taxes_counter 0
db_foreach get_sales_taxes "select state_name, tax_rate*100 as tax_rate_in_percent, decode(shipping_p,'t','Yes','No') as shipping_p
from ec_sales_tax_by_state, us_states
where ec_sales_tax_by_state.usps_abbrev = us_states.abbrev" {
    incr taxes_counter
    append sales_taxes_html "<li>$state_name:
<ul><li>Tax rate: $tax_rate_in_percent%</li>
<li>Charge tax on shipping? $shipping_p</li></ul></li>"

} 

set current_state_list [db_list get_abbrevs "select usps_abbrev from ec_sales_tax_by_state"]

db_release_unused_handles

set state_widget_html "[ec_multiple_state_widget $current_state_list]"

set audit_url_html "[ec_url_concat [ec_url] /admin]/audit-tables?[export_url_vars table_names_and_id_column]"


