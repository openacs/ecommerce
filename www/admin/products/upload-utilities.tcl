#  www/[ec_url_concat [ec_url] /admin]/products/upload-utilities.tcl
ad_page_contract {
  Upload utilites admin page.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
}

ad_require_permission [ad_conn package_id] admin

set title "Upload Utilities"
set context [list $title]


