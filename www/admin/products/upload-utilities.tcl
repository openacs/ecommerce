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

set page_title "Upload Utilities"
set context_bar [template::adp_parse [acs_root_dir]/packages/[ad_conn package_key]/www/contextbar [list context_addition "Upload Utilities"]]

