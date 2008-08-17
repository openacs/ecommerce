ad_page_contract {

    Add a creditcard.

    @author Eve Andersson (eveander@arsdigita.com)
    @creation-date Summer 1999
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @revision-date April 2002

} {
    order_id:integer,notnull
}

ad_require_permission [ad_conn package_id] admin

set title "New Credit Card"
set context [list [list index "Orders / Shipments / Refunds"] $title]

db_0or1row select_billing_address "
      select c.billing_address, a.country_code
      from ec_creditcards c, ec_orders o, ec_addresses a
      where o.creditcard_id = c.creditcard_id
      and a.address_id = c.billing_address
      and o.order_id = :order_id
      limit 1"

set billing_address_html "[ec_display_as_html [ec_pretty_mailing_address_from_ec_addresses $billing_address]]"

set export_form_vars_html [export_form_vars order_id]
set credit_card_type_html [ec_creditcard_widget]
set credit_card_exp_html "[ec_creditcard_expire_1_widget] [ec_creditcard_expire_2_widget]"
