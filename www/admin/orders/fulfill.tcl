# /www/[ec_url_concat [ec_url] /admin]/orders/fulfill.tcl
ad_page_contract {
  Fulfill an order.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  order_id:integer,notnull
}

ad_require_permission [ad_conn package_id] admin

auth::require_login

set user_id [db_string user_id_select "
select user_id
  from ec_orders
 where order_id=:order_id"]

set title "Order Fulfillment"
set context [list [list index "Orders / Shipments / Refunds"] $title]

set export_form_vars_html [export_form_vars order_id]

set shipping_method [db_string shipping_method_select "select shipping_method
  from ec_orders
 where order_id=:order_id"]

set shipping_method_html "[ec_decode $shipping_method "no shipping" "Check off the items that have been fulfilled" "Check off the shipped items"]:"

set items_for_fulfillment [ec_items_for_fulfillment_or_return $order_id "t"]


set shipping_time_html "[ad_dateentrywidget shipment_date] [ec_timeentrywidget shipment_time]"

if { ![string equal $shipping_method "no shipping" } {

    set expected_arrival_time "[ad_dateentrywidget expected_arrival_date ""] [ec_timeentrywidget expected_arrival_time ""]"
    # carrier list is hardcoded because we need carrier names to be exactly what we have here for connecting to package tracking pages

}
