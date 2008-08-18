#  www/[ec_url_concat [ec_url] /admin]/shipping-costs/examples.tcl
ad_page_contract {

  @author
  @creation-date
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
}

ad_require_permission [ad_conn package_id] admin

set title "Examples"
set context [list [list index "Shipping Costs"] $title]











