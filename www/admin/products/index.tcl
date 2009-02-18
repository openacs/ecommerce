#  www/[ec_url_concat [ec_url] /admin]/products/index.tcl
ad_page_contract {
  The main admin page for products.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
}

ad_require_permission [ad_conn package_id] admin

set title "Product Administration"
set context [list $title]

# For Audit tables
set table_names_and_id_column [list ec_products ec_products_audit product_id]
set audit_html "[ec_url_concat [ec_url] /admin]/audit-tables?[export_url_vars table_names_and_id_column]"


db_1row products_select "select count(*) as n_products, round(avg(price),2) as avg_price from ec_products_displayable"

set repeat_skus [db_list possible_sku_ref_issues "select sku from ec_products where active_p = 't'  group by sku having count(sku) > 1"]
if { [llength $repeat_skus] > 0 } {
    set repeat_sku_warn 1
} else {
    set repeat_sku_warn 0
}

