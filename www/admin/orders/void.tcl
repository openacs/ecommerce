# /www/[ec_url_concat [ec_url] /admin]/orders/void.tcl
ad_page_contract {

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  order_id:integer,notnull
}

ad_require_permission [ad_conn package_id] admin

set title "Void"
set context [list [list index "Orders / Shipments / Refunds"] $title]

set n_shipped_items [db_string shipped_items_count "select count(*) from ec_items where order_id=:order_id and item_state in ('shipped', 'arrived', 'received_back')"]

set export_form_vars_html [export_form_vars order_id]

