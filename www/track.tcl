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

set user_id [ad_verify_and_get_user_id]
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
    set fedex_url "http://www.fedex.com/cgi-bin/tracking?tracknumbers=$tracking_number&action=track&language=english&cntry_code=us"
    with_catch errmsg {
	set page_from_fedex [ns_httpget $fedex_url]
	regexp {(<TABLE WIDTH="290".*?</TABLE>).*?(<TABLE WIDTH="460" BORDER="0" CELLPADDING="2" CELLSPACING="1">.*?</TABLE>)} $page_from_fedex \
	    match detailed_info scan_activity

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

set context_bar [template::adp_parse [acs_root_dir]/packages/[ad_conn package_key]/www/contextbar [list context_addition [list "Your Shipment"]]]
set ec_system_owner [ec_system_owner]
db_release_unused_handles
ad_return_template
