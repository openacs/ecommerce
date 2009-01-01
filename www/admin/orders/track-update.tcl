ad_page_contract {
    This script updates tracking for one shipment

} {
    order_id:integer,notnull
    shipment_id:integer,notnull
    expected_arrival_date:optional,array,date
    expected_arrival_time:optional,array,time
    {carrier ""}
    {tracking_number ""}
}

ad_maybe_redirect_for_registration
set ip_address [ns_conn peeraddr]
set user_id [ad_verify_and_get_user_id]

if { ![info exists expected_arrival_date(date)] } {
    set expected_arrival_date(date) ""
} 

if { ![info exists expected_arrival_time(time)] } {
    set expected_arrival_time(time) ""
}

if { [info exists expected_arrival_time(ampm)] && $expected_arrival_time(ampm) eq "PM" } {
    # add 12 hours to time
    set expected_arrival_time(hours) [expr { int( $expected_arrival_time(hours) + 12 ) } ]
    set expected_arrival_time(time) "$expected_arrival_time(hours):$expected_arrival_time(minutes):$expected_arrival_time(seconds)"
}
set expected_arrival_date_time "$expected_arrival_date(date) $expected_arrival_time(time)"
ns_log Notice "track-update: $expected_arrival_date_time"
db_dml update_shipment_info "update ec_shipments 
        set expected_arrival_date = :expected_arrival_date_time, 
        carrier = :carrier, tracking_number= :tracking_number, 
        last_modified = now(), last_modifying_user = :user_id, modified_ip_address = :ip_address 
        where shipment_id = :shipment_id and order_id = :order_id"

ad_returnredirect "track?[export_url_vars shipment_id order_id]"


