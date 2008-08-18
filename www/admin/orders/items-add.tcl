ad_page_contract {

    Add an item to an order.

    @author Eve Andersson (eveander@arsdigita.com)
    @creation-date Summer 1999
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @revision-date April 2002

} {
    order_id:integer,notnull
}

ad_require_permission [ad_conn package_id] admin

set title "Add Items"
set context [list [list index "Orders / Shipments / Refunds"] $title]

set export_form_vars_html [export_form_vars order_id]
