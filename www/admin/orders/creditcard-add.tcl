# /www/[ec_url_concat [ec_url] /admin]/orders/creditcard-add.tcl
ad_page_contract {
  Add a creditcard.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id creditcard-add.tcl,v 3.1.6.3 2000/08/16 18:49:04 seb Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  order_id:integer,notnull
}

ad_require_permission [ad_conn package_id] admin

doc_body_append "[ad_admin_header "New Credit Card"]

<h2>New Credit Card</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index" "Orders"] [list "one?[export_url_vars order_id]" "One Order"] "New Credit Card"]

<hr>
Entering a new credit card will cause all future transactions involving this order
to use this credit card.  However, it will not have any effect on transactions that
are currently underway (e.g., if a transaction has already been authorized with a
different credit card, that credit card will be used to complete the transaction).
"


set zip_code [db_string zip_code_select "select zip_code from ec_addresses a, ec_orders o where a.address_id=o.shipping_address and order_id=:order_id"]

doc_body_append "<form method=post action=creditcard-add-2>
[export_form_vars order_id]
<blockquote>
<table>
<tr>
<td>Credit card number:</td>
<td><input type=text name=creditcard_number size=17></td>
</tr>
<tr>
<td>Type:</td>
<td>[ec_creditcard_widget]</td>
</tr>
<tr>
<td>Expires:</td>
<td>[ec_creditcard_expire_1_widget] [ec_creditcard_expire_2_widget]</td>
<tr>
<td>Billing zip code:</td>
<td><input type=text name=billing_zip_code value=\"$zip_code\" size=5></td>
</tr>
</table>
</blockquote>

<center>
<input type=submit value=\"Continue\">
</center>

</form>

[ad_admin_footer]
"
