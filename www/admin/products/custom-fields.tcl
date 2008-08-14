# /www/[ec_url_concat [ec_url] /admin]/products/custom-fields.tcl
ad_page_contract {
  Admin page for custom product fields.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
}

ad_require_permission [ad_conn package_id] admin

set title "Custom Fields"
set context [list [list index Products] $title]

set custom_fields_select_html ""
db_foreach custom_fields_select "
select field_identifier, field_name, active_p
from ec_custom_product_fields
order by active_p desc, field_name" {
  append custom_fields_select_html "<li><a href=\"custom-field?field_identifier=$field_identifier\">$field_name</a>"
  if { $active_p == "f" } {
    append custom_fields_select_html " (inactive)"
  }
}

set table_names_and_id_column [list ec_custom_product_fields ec_custom_product_fields_audit field_identifier]
set audit_url_html "[ec_url_concat [ec_url] /admin]/audit-tables?[export_url_vars table_names_and_id_column]"
