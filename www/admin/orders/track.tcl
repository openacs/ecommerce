# /www/[ec_url_concat [ec_url] /admin]/orders/track.tcl
ad_page_contract {
  Track a shipment. Somewhat configured for FedEx, UPS

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  shipment_id:integer,notnull
}

ad_require_permission [ad_conn package_id] admin

set title "Track Shipment"
set context [list [list index "Orders / Shipments / Refunds"] $title]

set carrier_list [db_list get_carrier_list "
    select distinct carrier
    from ec_shipments 
    where carrier is not null
    order by carrier"]



db_1row shipment_select "select to_char(shipment_date, 'MMDDYY') as ship_date_for_fedex, to_char(shipment_date, 'MM/DD/YYYY') as pretty_ship_date, carrier, tracking_number, expected_arrival_date, order_id
from ec_shipments
where shipment_id = :shipment_id"

set export_form_vars_html [export_form_vars shipment_id order_id]

set carrier_select_html "<select name=\"carrier\">"
foreach carrier_choice $carrier_list {
    if {$carrier_choice eq $carrier} {
        append carrier_select_html "<option value=\"$carrier_choice\" selected>$carrier_choice</option>"
    } else {
        append carrier_select_html "<option value=\"$carrier_choice\">$carrier_choice</option>"
    }
}
append carrier_select_html "</select>"

set carrier_info ""

if { $carrier == "FedEx" } {
    set fedex_url "http://www.fedex.com/Tracking?tracknumbers=${tracking_number}&language=english&cntry_code=us"
    set carrier_info "Unable to retrieve data from FedEx."
    if { [catch {set get_id [ns_http queue -timeout 65 $fedex_url]} err ]} {
        ns_log Error "ecommerce/www/admin/orders/track.tcl  url=$fedex_url error: $err"
    } else {
        ns_log Notice "ecommerce/www/admin/orders/track.tcl  ns_httping $fedex_url"

        if { [catch { ns_http wait -result page_from_fedex -status status $get_id } err2 ]} {
            ns_log Error "ecommerce/www/admin/orders/track.tcl  ns_http wait $err2"
        }
        
        if { ![info exists status] || $status ne "200" } {
            # no page info returned, just return error
            ns_log Warning "ecommerce/www/admin/orders/track.tcl Unable to retrieve FedEx data for ${tracking_number}. Error is $err"
        } else {
            # Received page, Remove links
            set scan_activity [ecds_get_contents_from_tag {<!-- BEGIN Scan Activity -->} {<!-- END Scan Activity -->} $page_from_fedex]
            set detailed_info [ecds_get_contents_from_tag {!-- shipment info -->} {<!-- BEGIN Scan Activity -->} $page_from_fedex]
            regsub -all -nocase {</*?a.*?>} $scan_activity "" scan_activity
            set carrier_info "$detailed_info $scan_activity"
        }
    }

} elseif { [string match "UPS*" $carrier] } {
    set ups_url "http://wwwapps.ups.com/WebTracking/track?HTMLVersion=5.0&loc=en_US&Requester=UPSHome&trackNums=$tracking_number&track.x=track"
    with_catch errmsg {
        set ups_page [ns_httpget $ups_url]
        if { [regexp {(<!-- Begin Summary List -->.*<!-- End Summary List -->)} $ups_page match ups_info] } {
            # Remove spacer images
            regsub -all -nocase {<img.*?>} $ups_info "" ups_info
            set carrier_info "<table noborder>$ups_info</table>"
        } elseif { [regexp {(<!-- Begin Package Progress -->.*<!-- End Package Progress -->)} $ups_page match ups_info] } {
            # Remove spacer images
            regsub -all -nocase {<img.*?>} $ups_info "" ups_info
            set carrier_info "<table noborder>$ups_info</table>"

        } else { 
            set carrier_info "Unable to parse detail data from UPS."
            ns_log Error "ecommerce/www/admin/orders/track.tcl: unable to parse detail data from UPS for order_id $order_id"
        }
    } {
        set carrier_info "Unable to retrieve data from UPS."
    } 
}
set carrier_name [ec_decode $carrier "" "Carrier" $carrier]
set carrier_tracking_info [ec_decode $carrier_info "" "Unvailable to retrieve details for this carrier." $carrier_info]
if { ![info exists expected_arrival_date] } {
    set expected_arrival_date 0
    set expected_arrival_time "5:00:00 PM"
} else {
    regsub {[ ]+} $expected_arrival_date { } expected_arrival_date
    set expected_arrival_date_list [split $expected_arrival_date " "]
    set expected_arrival_date [lindex $expected_arrival_date_list 0]
    set expected_arrival_time [lindex $expected_arrival_date_list 1]
}
set expected_arrival_html "[ad_dateentrywidget expected_arrival_date $expected_arrival_date] [ec_timeentrywidget expected_arrival_time $expected_arrival_time]"