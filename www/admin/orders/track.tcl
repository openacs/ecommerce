# /www/[ec_url_concat [ec_url] /admin]/orders/track.tcl
ad_page_contract {
  Track a shipment.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  shipment_id:integer,notnull
}

ad_require_permission [ad_conn package_id] admin

doc_body_append "[ad_admin_header "Track Shipment"]

<h2>Track Shipment</h2>

[ad_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index" "Orders"] [list "one?[export_url_vars order_id]" "One Order"] "Track Shipment"]

<hr>
"


db_1row shipment_select "
select to_char(shipment_date, 'MMDDYY') as ship_date_for_fedex, to_char(shipment_date, 'MM/DD/YYYY') as pretty_ship_date, carrier, tracking_number
from ec_shipments
where shipment_id = :shipment_id
"

set carrier_info ""

if { $carrier == "FedEx" } {
    set fedex_url "http://www.fedex.com/cgi-bin/tracking?tracknumbers=$tracking_number&action=track&language=english&cntry_code=us"
    with_catch errmsg {
	set page_from_fedex [ns_httpget $fedex_url]
	regexp {(<TABLE WIDTH="290".*?</TABLE>).*?(<TABLE WIDTH="460" BORDER="0" CELLPADDING="2" CELLSPACING="1">.*?</TABLE>)} $page_from_fedex match detailed_info scan_activity
	# Remove links
	regsub -all -nocase {</*?a.*?>} $scan_activity "" scan_activity
	set carrier_info "$detailed_info $scan_activity"
    } {
	set carrier_info "Unable to retrieve data from FedEx."
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

doc_body_append "<ul>
<li>Shipping Date: $pretty_ship_date
<li>Carrier: $carrier
<li>Tracking Number: $tracking_number
</ul>

<h4>Information from [ec_decode $carrier "" "Carrier" $carrier]</h4>

<blockquote>
[ec_decode $carrier_info "" "None Available" $carrier_info]
</blockquote>

[ad_admin_footer]
"
