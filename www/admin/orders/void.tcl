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

doc_body_append "[ad_admin_header "Void Order"]

<h2>Void Order</h2>

[ad_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index" "Orders"] [list "one?[export_url_vars order_id]" "One Order"] "Void"]

<hr>
"

set n_shipped_items [db_string shipped_items_count "select count(*) from ec_items where order_id=:order_id and item_state in ('shipped', 'arrived', 'received_back')"]

if { $n_shipped_items > 0 } {
    doc_body_append "<font color=red>Warning:</font> our records show that at least one item in this
    order has already shipped, which means that the customer has already been charged
    (for shipped items only).  Voiding an order will not cause
    the customer's credit card to be refunded (you can only do that by marking
    individual items \"received back\").
    <p>
    Voiding is usually done if the customer cancels their order before it ships. 
    <p>
    "
}

doc_body_append "Note: this will cause all individual items in this order
to be marked 'void'.
<p>"

doc_body_append "
<form method=post action=void-2>
[export_form_vars order_id]

Please explain why you are voiding this order:

<br>

<blockquote>
<textarea name=reason_for_void rows=5 cols=50 wrap>
</textarea>
</blockquote>

<p>
<center>
<input type=submit value=\"Void It!\">
</center>

</form>

[ad_admin_footer]
"
