ad_page_contract {
    New shipping address.

    @author Eve Andersson (eveander@arsdigita.com)
    @creation-date Summer 1999
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @revision-date April 2002

} {
    order_id:integer,notnull
    creditcard_id:integer,optional
}

ad_require_permission [ad_conn package_id] admin

set title "New Shipping Address"
set context [list [list index "Orders / Shipments / Refunds"] $title]

set user_name [db_string user_name_select "
    select first_names || ' ' || last_name 
    from cc_users, ec_orders 
    where ec_orders.user_id=cc_users.user_id 
    and order_id=:order_id" -default ""]

set export_domestic_form_vars_html [export_form_vars order_id creditcard_id]
set export_international_form_vars_html [export_form_vars order_id creditcard_id]
set state_widget_html [state_widget]
set country_widget_html [ec_country_widget]
