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

ad_maybe_redirect_for_registration

set user_id [db_string user_id_select "
select user_id
  from ec_orders
 where order_id=:order_id"]

doc_body_append "<head>
<title>Order Fulfillment</title>
</head>
<body bgcolor=white text=black>

<h2>Order Fulfillment</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index" "Orders"] [list "fulfillment" "Fulfillment"] "One Order"]

<hr>

<form name=fulfillment_form method=post action=fulfill-2>
[export_form_vars order_id]
"

set shipping_method [db_string shipping_method_select "
select shipping_method
  from ec_orders
 where order_id=:order_id
"]

doc_body_append "
[ec_decode $shipping_method "no shipping" "Check off the items that have been fulfilled" "Check off the shipped items"]:

<blockquote>
[ec_items_for_fulfillment_or_return $order_id "t"]
</blockquote>
"

if { $shipping_method != "no shipping" } {

    doc_body_append "<p>
<br>
Enter the following if relevant:

<blockquote>
<table>
<tr>
<td>Shipment date (required):</td>
<td>[ad_dateentrywidget shipment_date] [ec_timeentrywidget shipment_time]</td>
</tr>
<tr>
<td>Expected arrival date:</td>
<td>[ad_dateentrywidget expected_arrival_date ""] [ec_timeentrywidget expected_arrival_time ""]</td>
</tr>
<tr>
<td>Carrier</td>
<td>
<!-- the reason these are hardcoded is that we need carrier names to be exactly what we have here if we're going to be able to construct the package tracking pages -->
<select name=carrier>
<option value=\"\">select one
<option value=\"FedEx\">FedEx
<option value=\"UPS Ground\">UPS Ground
<option value=\"UPS Air\">UPS Air
<option value=\"US Priority\">US Priority
<option value=\"USPS\">USPS
</select>

Other:
<input type=text name=carrier_other size=10>
</td>
</tr>
<tr>
<td>Tracking Number</td>
<td><input type=text name=tracking_number size=20></td>
</tr>
</table>
</blockquote>
"
} else {
    doc_body_append "Fulfillment date (required):
[ad_dateentrywidget shipment_date] [ec_timeentrywidget shipment_time]
<p>
"
}

doc_body_append "<center>
<input type=submit value=\"Continue\">
</center>

</form>

[ad_admin_footer]
"
