#  www/[ec_url_concat [ec_url] /admin]/products/supporting-file-delete-2.tcl
ad_page_contract {
  Delete a file.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id supporting-file-delete-2.tcl,v 3.3.2.2 2000/07/22 07:57:46 ron Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  product_id:integer,notnull
  file
}

ad_require_permission [ad_conn package_id] admin

if { [regexp {/} $file] } {
    error "Invalid filename."
}

set dirname [db_string dirname_select "select dirname from ec_products where product_id=:product_id"]
db_release_unused_handles

set subdirectory [ec_product_file_directory $product_id]

set full_dirname "[ec_data_directory][ec_product_directory]$subdirectory/$dirname"

ns_unlink $full_dirname/$file

ad_returnredirect "supporting-files-upload.tcl?[export_url_vars product_id]"
