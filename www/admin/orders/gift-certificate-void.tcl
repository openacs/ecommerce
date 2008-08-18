# /www/[ec_url_concat [ec_url] /admin]/orders/gift-certificate-void.tcl
ad_page_contract {

  Void a gift certificate.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  gift_certificate_id:integer,notnull
}

ad_require_permission [ad_conn package_id] admin

set title "Void Gift Certificate"
set context [list [list index "Orders / Shipments / Refunds"] $title]

set export_form_vars_html [export_form_vars gift_certificate_id]

