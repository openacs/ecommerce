# /www/[ec_url_concat [ec_url] /admin]/orders/comments-edit.tcl
ad_page_contract {

  Update the comments field of ec_orders.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  order_id:integer,notnull
  cs_comments
}

ad_require_permission [ad_conn package_id] admin

db_dml cs_comments_update "update ec_orders set cs_comments=:cs_comments where order_id=:order_id"

ad_returnredirect "one?[export_url_vars order_id]"
