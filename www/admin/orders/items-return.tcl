# /www/[ec_url_concat [ec_url] /admin]/orders/items-return.tcl
ad_page_contract {

  Return items.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id items-return.tcl,v 3.3.2.4 2000/08/17 15:19:14 seb Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  order_id:integer,notnull
}

ad_require_permission [ad_conn package_id] admin

# in case they reload this page after completing the refund process:
if { [db_string doubleclick_select "select count(*) from ec_items_refundable where order_id=:order_id"] == 0 } {
    ad_return_complaint 1 "<li>This order doesn't contain any refundable items; perhaps you are using an old form.  <a href=\"one?[export_url_vars order_id]\">Return to the order.</a>"
    return
}

doc_body_append "[ad_admin_header "Mark Items Returned"]

<h2>Mark Items Returned</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index" "Orders"] [list "one?order_id=$order_id" "One Order"] "Mark Items Returned"]

<hr>
"

# generate the new refund_id here (we don't want them reusing this form)
set refund_id [db_string refund_id_select "select refund_id_sequence.nextval from dual"]

doc_body_append "<form method=post action=items-return-2>
[export_form_vars order_id refund_id]

<blockquote>
Date received back:
[ad_dateentrywidget received_back_date]&nbsp;[ec_timeentrywidget received_back_time]

<p>

Please check off the items that were received back:
<blockquote>
[ec_items_for_fulfillment_or_return $order_id "f"]
</blockquote>

Reason for return (if known):
<blockquote>
<textarea name=reason_for_return rows=5 cols=50 wrap>
</textarea>
</blockquote>

</blockquote>

<p>
<center>
<input type=submit value=\"Continue\">
</center>

</form>

[ad_admin_footer]
"
