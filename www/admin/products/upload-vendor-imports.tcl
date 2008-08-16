#  www/[ec_url_concat [ec_url] /admin]/products/upload.tcl
ad_page_contract {
  This page uploads a data file containing store-specific products into
  the catalog. The file format should be:

  one product reference per line
} {
}

ad_require_permission [ad_conn package_id] admin

set title "Import Vendors Products"
set context [list [list index Products] $title]

set vendor_choose_widget_html [ecds_vendor_choose_widget]
