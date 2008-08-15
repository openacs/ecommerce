#  www/[ec_url_concat [ec_url] /admin]/products/extras-upload.tcl
ad_page_contract {
  This page uploads a CSV file containing client-specific product
  information into the catalog. The file format should be:

    field_name_1, field_name_2, ... field_name_n
    value_1, value_2, ... value_n

  where the first line contains the actual names of the columns in
  ec_custom_product_field_values and the remaining lines contain the
  values for the specified fields, one line per product.

  Legal values for field names are site-specific: whatever additional
  fields the administrator has created prior to loading a file can be
  populated by this script.

  Note: last_modified, last_modifying_user and modified_ip_address are
  set automatically and should not appear in the data file.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
}

ad_require_permission [ad_conn package_id] admin

set title "Upload Product Extras"
set context [list [list index Products] $title]

db_with_handle db {
    for {set i 0} {$i < [ns_column count $db ec_custom_product_field_values]} {incr i} {
        set col_to_print [ns_column name $db ec_custom_product_field_values $i]
        set undesirable_cols [list "available_date" "last_modified" "last_modifying_user" "modified_ip_address"]
        set required_cols [list "product_id"]
        if { [lsearch -exact $undesirable_cols $col_to_print] == -1 } {
            append doc_body "$col_to_print"
            if { [lsearch -exact $required_cols $col_to_print] != -1 } {
                append doc_body " (required, can use sku as key instead)"
            }
            append doc_body "\n"
        }
    }
}

set undesirable_cols_html [join $undesirable_cols ", "]
