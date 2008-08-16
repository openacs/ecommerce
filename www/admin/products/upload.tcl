#  www/[ec_url_concat [ec_url] /admin]/products/upload.tcl
ad_page_contract {
  This page uploads a data file containing store-specific products into
  the catalog. The file format should be:

    field_name_1, field_name_2, ... field_name_n
    value_1, value_2, ... value_n

  where the first line contains the actual names of the columns in
  ec_products and the remaining lines contain the values for the
  specified fields, one line per product.

  Legal values for field names are the columns in ec_products (see
  ecommerce/sql/ecommerce-create.sql for current column names):

    sku
    product_name (required)
    one_line_description:html
    detailed_description:html
    search_keywords
    price
    shipping
    shipping_additional
    weight
    dirname
    present_p
    active_p
    available_date
    announcements
    announcements_expire
    url
    template_id
    stock_status

  Note: product_id, dirname, creation_date, available_date, last_modified,
  last_modifying_user and modified_ip_address are set automatically
  and should not appear in the CSV file.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
}

ad_require_permission [ad_conn package_id] admin

set title "Upload Products"
set context [list [list index Products] $title]

set undesirable_cols [list "product_id" "dirname" "creation_date" "available_date" "last_modified" "last_modifying_user" "modified_ip_address"]

set required_cols [list "sku" "product_name"]

db_with_handle db {
  for {set i 0} {$i < [ns_column count $db ec_products]} {incr i} {
    set col_to_print [ns_column name $db ec_products $i]
    if { [lsearch -exact $undesirable_cols $col_to_print] == -1 } {
      append doc_body "$col_to_print"
      if { [lsearch -exact $required_cols $col_to_print] != -1 } {
          append doc_body " (required)"
      }
      append doc_body "\n"
    }
  }
}

set undesirable_cols_html [join $undesirable_cols ", "]


