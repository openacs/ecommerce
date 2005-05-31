# /www/[ec_url_concat [ec_url] /admin]/orders/void-2.tcl
ad_page_contract {

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  order_id:integer,notnull
  reason_for_void
}

ad_require_permission [ad_conn package_id] admin

ad_maybe_redirect_for_registration
set customer_service_rep [ad_get_user_id]

db_transaction {
  db_dml order_update "
  update ec_orders
  set order_state='void',
  reason_for_void=:reason_for_void,
  voided_by=:customer_service_rep,
  voided_date=sysdate
  where order_id=:order_id
  "

  db_dml items_update "
  update ec_items
  set item_state='void',
  voided_by=:customer_service_rep
  where order_id=:order_id
  "

  # Reinstate gift certificates.
  db_exec_plsql gift_certificates_reinst "declare begin ec_reinst_gift_cert_on_order(:order_id); end;"
}

ad_returnredirect "one?[export_url_vars order_id]"
