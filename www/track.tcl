ad_page_contract {
    @param shipment_id The ID of the shipment to track
    @param ucsa_p User session begun or not

    @author
    @creation-date
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @revision-date April 2002

} {
    shipment_id:notnull,naturalnum
    ucsa_p:optional
}

set user_id [ad_conn user_id]
if {$user_id == 0} {
    set return_url "[ad_conn url]"
    ad_returnredirect "/register?[export_url_vars return_url]"
    ad_script_abort
}

# user session tracking

set user_session_id [ec_get_user_session_id]
ec_create_new_session_if_necessary [export_url_vars shipment_id]
ec_log_user_as_user_id_for_this_session

# Make sure this order belongs to the user.

if { [db_string assure_order_is_this_user "
    select user_id from ec_orders o, ec_shipments s
    where o.order_id = s.order_id
    and s.shipment_id = :shipment_id"] != $user_id } {
    ad_return_error "Invalid Order ID" "Invalid Order ID"
    ad_script_abort
}

db_1row get_order_info "
    select to_char(shipment_date, 'MMDDYY') as ship_date_for_fedex, to_char(shipment_date, 'MM/DD/YYYY') as pretty_ship_date, carrier, tracking_number
    from ec_shipments
    where shipment_id = :shipment_id"
set carrier_info ""
if { $carrier == "FedEx" } {

    set fedex_url "http://www.fedex.com/Tracking?tracknumbers=${tracking_number}&language=english&cntry_code=us"
    set carrier_info "Unable to retrieve data from FedEx."
    if { [catch {set get_id [ns_http queue -timeout 65 $fedex_url]} err ]} {
        ns_log Error "ecommerce/www/track.tcl  url=$fedex_url error: $err"
    } else {
        ns_log Notice "ecommerce/www/track.tcl  ns_httping $fedex_url"

        if { [catch { ns_http wait -result page_from_fedex -status status $get_id } err2 ]} {
            ns_log Error "ecommerce/www/track.tcl  ns_http wait $err2"
        }
        
        if { ![info exists status] || $status ne "200" } {
            # no page info returned, just return error
            ns_log Warning "ecommerce/www/track.tcl Unable to retrieve FedEx data for ${tracking_number}. Error is $err"
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
            ns_log Error "ecommerce/www/track.tcl: unable to parse detail data from UPS for order_id $order_id"
        }
    } {
        set carrier_info "Unable to retrieve data from UPS."
    } 

}

set title "Your Shipment"
set context [list $title]
set ec_system_owner [ec_system_owner]
db_release_unused_handles
ad_return_template
