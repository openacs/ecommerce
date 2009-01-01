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

db_1row shipment_select "select to_char(shipment_date, 'MMDDYY') as ship_date_for_fedex, to_char(shipment_date, 'MM/DD/YYYY') as pretty_ship_date, carrier, tracking_number
from ec_shipments
where shipment_id = :shipment_id"

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
            ns_log Warning "ecommerce/www/admin/orders/track.tcl Unable to retrieve FedEx data for ${tracking_number}. Error is $errmsg"
        } else {
            # Received page, Remove links
            set scan_activity [ecds_get_contents_from_tag {<!-- BEGIN Scan Activity -->} {<!-- END Scan Activity -->} $page_from_fedex]
            set detailed_info [ecds_get_contents_from_tag {!-- shipment info -->} {<!-- BEGIN Scan Activity -->} $page_from_fedex]
            regsub -all -nocase {</*?a.*?>} $scan_activity "" scan_activity
            set carrier_info "$detailed_info $scan_activity"
        }
    }

} elseif { [string match "UPS*" $carrier] } {
    set ups_url "http://wwwapps.ups.com/etracking/tracking.cgi?submit=Track&InquiryNumber1=$tracking_number&TypeOfInquiryNumber=T&build_detail=yes"
    with_catch errmsg {
        set ups_page [ns_httpget $ups_url]
        if { ![regexp {(<TR><TD[^>]*>Tracking Number:.*</TABLE>).*Tracking results provided by UPS} $ups_page match ups_info] } {
            set carrier_info "Unable to parse detail data from UPS."
        } else {
            # Remove spacer images
            regsub -all -nocase {<img.*?>} $ups_info "" ups_info
            set carrier_info "<table noborder>$ups_info"
        }
    } {
        set carrier_info "Unable to retrieve data from UPS."
    } 
}
set carrier_name [ec_decode $carrier "" "Carrier" $carrier]
set carrier_tracking_info [ec_decode $carrier_info "" "Unvailable to retrieve details for this carrier." $carrier_info]
