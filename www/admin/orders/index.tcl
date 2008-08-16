ad_page_contract {

    The main page for the orders section of the ecommerce admin pages.

    @author Eve Andersson (eveander@arsdigita.com)
    @creation-date Summer 1999
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @revision-date April 2002

} {
}

ad_require_permission [ad_conn package_id] admin

set title "Orders / Shipments / Refunds"
set context [list $title]

db_1row recent_orders_select "select sum(one_if_within_n_days(confirmed_date,1)) as n_o_in_last_24_hours, sum(one_if_within_n_days(confirmed_date,7)) as n_o_in_last_7_days
    from ec_orders_reportable"

db_1row recent_baskets_select "select sum(one_if_within_n_days(in_basket_date,1)) as s_b_in_last_24_hours, sum(one_if_within_n_days(in_basket_date,7)) as s_b_in_last_7_days
    from ec_orders"

db_1row recent_gift_certificates_purchased_select "select sum(one_if_within_n_days(issue_date,1)) as n_g_in_last_24_hours, sum(one_if_within_n_days(issue_date,7)) as n_g_in_last_7_days
    from ec_gift_certificates_purchased"

db_1row recent_gift_certificates_issued_select "select sum(one_if_within_n_days(issue_date,1)) as n_gi_in_last_24_hours, sum(one_if_within_n_days(issue_date,7)) as n_gi_in_last_7_days
    from ec_gift_certificates_issued"

db_1row recent_shipments_select "select sum(one_if_within_n_days(shipment_date,1)) as n_s_in_last_24_hours, sum(one_if_within_n_days(shipment_date,7)) as n_s_in_last_7_days
    from ec_shipments"

db_1row recent_refunds_select "select sum(one_if_within_n_days(refund_date,1)) as n_r_in_last_24_hours, sum(one_if_within_n_days(refund_date,7)) as n_r_in_last_7_days
    from ec_refunds"

set count 0
set shipping_method_counts_html ""
db_foreach shipping_method_counts "
    select shipping_method, coalesce(count(*), 0) as shipping_method_count
    from ec_orders_shippable
    where shipping_method not in ('no_shipping', 'pickup')
    and shipping_method is not null
    group by shipping_method" {

    incr count
    if {$count == 1} {
        append shipping_method_counts_html "("
    }
    append shipping_method_counts_html "$shipping_method_count to be shipped via $shipping_method"
    if {$count < [db_resultrows]} {
        append shipping_method_counts_html ", "
    } else {
        append shipping_method_counts_html ")"
    }
}

# show a zero instead of blank for values of zero
foreach date_range { n_o_in_last_24_hours n_o_in_last_7_days s_b_in_last_24_hours s_b_in_last_7_days n_g_in_last_24_hours n_g_in_last_7_days n_gi_in_last_24_hours n_gi_in_last_7_days n_s_in_last_24_hours n_s_in_last_7_days n_r_in_last_24_hours n_r_in_last_7_days } {
    set var_value [string trim [expr "$$date_range" ]]
    if { [string length $var_value] eq 0 } {
        set $date_range 0
    }
}
