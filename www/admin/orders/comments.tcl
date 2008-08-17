#  www/[ec_url_concat [ec_url] /admin]/orders/comments.tcl
ad_page_contract {
  Add and edit comments for an order.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  order_id:integer,notnull
}

ad_require_permission [ad_conn package_id] admin

set title "Comments"
set context [list [list index "Orders / Shipments / Refunds"] $title]

set export_form_vars_html [export_form_vars order_id]

set previous_comments [db_string comments_select "select cs_comments from ec_orders where order_id=:order_id"]


