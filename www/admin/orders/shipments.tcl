# /www/[ec_url_concat [ec_url] /admin]/orders/shipments.tcl
ad_page_contract {

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id shipments.tcl,v 3.2.2.4 2000/08/18 20:23:44 stevenp Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  {view_carrier "all"}
  {view_shipment_date "all"}
  {order_by "shipment_id"}
}

ad_require_permission [ad_conn package_id] admin

doc_body_append "[ad_admin_header "Shipment History"]

<h2>Shipment History</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index" "Orders"] "Shipment History"]

<hr>

<table border=0 cellspacing=0 cellpadding=0 width=100%>
<tr bgcolor=ececec>
<td align=center><b>Carrier</b></td>
<td align=center><b>Shipment Date</b></td>
</tr>
<tr>
<td align=center>
"



set carrier_list [db_list get_carrier_list "select unique carrier from ec_shipments where carrier is not null order by carrier"]
set carrier_list [concat "all" $carrier_list]

set linked_carrier_list [list]

foreach carrier $carrier_list {
    if {$view_carrier == $carrier} {
	lappend linked_carrier_list "<b>$carrier</b>"
    } else {
	lappend linked_carrier_list "<a href=\"shipments?[export_url_vars view_shipment_date order_by]&view_carrier=[ns_urlencode $carrier]\">$carrier</a>"
    }
}

doc_body_append "\[ [join $linked_carrier_list " | "] \]
</td>
<td align=center>
"

set shipment_date_list [list [list last_24 "last 24 hrs"] [list last_week "last week"] [list last_month "last month"] [list all all]]

set linked_shipment_date_list [list]

foreach shipment_date $shipment_date_list {
    if {$view_shipment_date == [lindex $shipment_date 0]} {
	lappend linked_shipment_date_list "<b>[lindex $shipment_date 1]</b>"
    } else {
	lappend linked_shipment_date_list "<a href=\"shipments?[export_url_vars view_carrier order_by]&view_shipment_date=[lindex $shipment_date 0]\">[lindex $shipment_date 1]</a>"
    }
}

doc_body_append "\[ [join $linked_shipment_date_list " | "] \]

</td></tr></table>

</form>
<blockquote>
"

if { $view_carrier == "all" } {
    set carrier_query_bit ""
} else {
    set carrier_query_bit "s.carrier=:view_carrier"
}

if { $view_shipment_date == "last_24" } {
    #set shipment_date_query_bit "sysdate-s.shipment_date <= 1"
    set shipment_date_query_bit [db_map last_24]
} elseif { $view_shipment_date == "last_week" } {
    #set shipment_date_query_bit "sysdate-s.shipment_date <= 7"
    set shipment_date_query_bit [db_map last_week]
} elseif { $view_shipment_date == "last_month" } {
    #set shipment_date_query_bit "months_between(sysdate,s.shipment_date) <= 1"
    set shipment_date_query_bit [db_map last_month]
} else {
    set shipment_date_query_bit ""
}

if { [empty_string_p $carrier_query_bit] && [empty_string_p $shipment_date_query_bit] } {
    set where_clause ""
} elseif { [empty_string_p $carrier_query_bit] } {
    set where_clause "where $shipment_date_query_bit"
} elseif { [empty_string_p $shipment_date_query_bit] } {
    set where_clause "where $carrier_query_bit"
} else {
    set where_clause "where $shipment_date_query_bit and $carrier_query_bit"
}

set link_beginning "shipments?[export_url_vars view_carrier view_shipment_date]"

set order_by_clause [util_decode $order_by \
    "shipment_id" "s.shipment_id" \
    "shipment_date" "s.shipment_date" \
    "order_id" "s.order_id" \
    "carrier" "s.carrier" \
    "n_items" "n_items" \
    "full_or_partial" "full_or_partial"]

set table_header "<table>
<tr>
<td><b><a href=\"$link_beginning&order_by=[ns_urlencode "shipment_id"]\">Shipment ID</a></b></td>
<td><b><a href=\"$link_beginning&order_by=[ns_urlencode "shipment_date"]\">Date Shipped</a></b></td>
<td><b><a href=\"$link_beginning&order_by=[ns_urlencode "order_id"]\">Order ID</a></b></td>
<td><b><a href=\"$link_beginning&order_by=[ns_urlencode "carrier"]\">Carrier</a></b></td>
<td><b><a href=\"$link_beginning&order_by=[ns_urlencode "n_items"]\"># of Items</a></b></td>
<td><b><a href=\"$link_beginning&order_by=[ns_urlencode "full_or_partial"]\">Full / Partial</a></b></td>
</tr>"

# set selection [ns_db select $db "select s.shipment_id, s.shipment_date, s.order_id, s.carrier, decode((select count(*) from ec_items where order_id=s.order_id),(select count(*) from ec_items where shipment_id=s.shipment_id),'Full','Partial') as full_or_partial, (select count(*) from ec_items where shipment_id=s.shipment_id) as n_items
# from ec_shipments s
# $where_clause
# order by $order_by"]

set row_counter 0

db_foreach shipments_select "
select s.shipment_id, 
       s.shipment_date, 
       s.order_id, 
       s.carrier, 
       decode(nvl((select count(*) from ec_items where order_id=s.order_id),0),nvl((select count(*) from ec_items where shipment_id=s.shipment_id),0),'Full','Partial') as full_or_partial,
       nvl((select count(*) from ec_items where shipment_id=s.shipment_id),0) as n_items
from ec_shipments s
$where_clause
order by $order_by_clause" {
    if { $row_counter == 0 } {
	doc_body_append $table_header
    }
    # even rows are white, odd are grey
    if { [expr floor($row_counter/2.)] == [expr $row_counter/2.] } {
	set bgcolor "white"
    } else {
	set bgcolor "ececec"
    }
    doc_body_append "<tr bgcolor=\"$bgcolor\">
<td>$shipment_id</td>
<td>[ec_nbsp_if_null [util_AnsiDatetoPrettyDate $shipment_date]]</td>
<td><a href=\"one?[export_url_vars order_id]\">$order_id</a></td>
<td>[ec_nbsp_if_null $carrier]</td>
<td>$n_items</td>
<td>$full_or_partial</td></tr>
    "
    incr row_counter
}

if { $row_counter != 0 } {
    doc_body_append "</table>"
} else {
    doc_body_append "<center>None Found</center>"
}

doc_body_append "</blockquote>

[ad_admin_footer]
"
