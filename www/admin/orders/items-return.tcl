ad_page_contract {

    Return items.

    @author Eve Andersson (eveander@arsdigita.com)
    @creation-date Summer 1999
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @revision-date April 2002

} {
    order_id:integer,notnull
}

ad_require_permission [ad_conn package_id] admin

# In case they reload this page after completing the refund process:
if { [db_string doubleclick_select "
    select count(*) 
    from ec_items_refundable 
    where order_id=:order_id"] == 0 } {
    
    ad_return_complaint 1 "
	<li>This order doesn't contain any refundable items; perhaps you are using an old form. <a href=\"one?[export_url_vars order_id]\">Return to the order.</a></li>"
    return
}

set title "Mark Items Returned"
set context [list [list index "Orders / Shipments / Refunds"] $title]

# Generate the new refund_id to prevent reusing this form.
set refund_id [db_nextval refund_id_sequence]

set export_form_vars_html [export_form_vars order_id refund_id]
set date_received_back_html "[ad_dateentrywidget received_back_date]&nbsp;[ec_timeentrywidget received_back_time]"
set items_for_return_html "[ec_items_for_fulfillment_or_return $order_id "f"]"
