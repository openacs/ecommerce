#  www/[ec_url_concat [ec_url] /admin]/products/upload-vendor-imports-2.tcl
ad_page_contract {

  @author
  @creation-date
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    vendor_sku_string
    abbrev
}

set doc_body ""
# We need them to be logged in
ad_require_permission [ad_conn package_id] admin
set user_id [ad_get_user_id]
set peeraddr [ns_conn peeraddr]
set serious_errors 0
# Grab package_id as context_id
set context_id [ad_conn package_id]

set title "Import / Add Vendors Products"
set context [list [list index Products] $title]

# Check that vendor abbrev length is > 0
if { [string length $abbrev] == 0 } {
    append doc_body "Vendor abbreviation does not exist."
    set serious_errors 1
}

# Start reading.

set count 0
set errors $serious_errors
set success_count 0

regsub -all -- {[^a-zA-Z0-9\-_\(\)\[\]\.] } $vendor_sku_string { } vendor_sku_string
set vendor_sku_list [split $vendor_sku_string]
foreach vendor_sku $vendor_sku_list {
    set vendor_code [string trim $vendor_sku]
    set product_id [ecds_import_product_from_vendor_site $abbrev vendor $vendor_code]
    incr count
    if { $product_id == -1 } {
        ns_log Warning "vendor-imports-add-update-2.tcl: Unable to import \"${vendor_code}\"."
    } else {
        incr success_count
    }
}

if { $success_count == 1 } {
    set product_string "product"
} else {
    set product_string "products"
}

set line_count [ec_decode $count "0" "0" [expr $count -1]]
