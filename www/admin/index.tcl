# www/[ec_url_concat [ec_url] /admin]/index.tcl
ad_page_contract {
  Ecommerce administration index page.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    {flush_db_cache 0}
}

ad_require_permission [ad_conn package_id] admin

set ec_url [ec_url]

# get data for user class links
set user_classes_reqs_approval [ad_parameter -package_id [ec_id] UserClassAllowSelfPlacement ecommerce]
set n_not_yet_approved [db_string non_approved_users_select "select count(*) from ec_user_class_user_map where user_class_approved_p is null or user_class_approved_p='f'"]

# orders

db_1row num_orders_select "
    select 
      sum(one_if_within_n_days(confirmed_date,1)) as n_in_last_24_hours,
      sum(one_if_within_n_days(confirmed_date,7)) as n_in_last_7_days
    from ec_orders_reportable"

# show a zero instead of blank for values of zero
foreach date_range { n_in_last_24_hours n_in_last_7_days } {
    set var_value [string trim [expr "$$date_range" ]]
    if { [string length $var_value] eq 0 } {
        set $date_range 0
    }
}


db_1row num_products_select "select count(*) as n_products, coalesce(round(avg(price),2), 0) as avg_price from ec_products_displayable"

# links and info mainly related to business operations

# customer service

set num_open_issues [db_string open_issues_select "select count(*) from ec_customer_service_issues where close_date is null"]

# surely an easier way than this?
set num_classes_not_yet_approved_plural [ec_decode $n_not_yet_approved 1 "" "s"]

set product_comments_allowed [ad_parameter -package_id [ec_id] ProductCommentsAllowP ecommerce]
set num_non_approved_comments [db_string non_approved_comments_select "select count(*) from ec_product_comments where approved_p is null"]


# recommend products
set pretty_avg_price [ec_pretty_pure_price $avg_price]


# links and info mainly related to website administration

set unresolved_problem_count [db_string unresolved_problem_count_select "select count(*) from ec_problems_log where resolved_date is null"]
set unresolved_problem_count_plural [ec_decode $unresolved_problem_count 1 "" "s"]

set paymentgateway_key [parameter::get -package_id [ec_id] -parameter PaymentGateway -default ""]
set paymentgateway_show 0
if { [string length $paymentgateway_key] > 1 } {
    set paymentgateway_url [file join [apm_package_url_from_key $paymentgateway_key] admin]
    set paymentgateway_show 1
}


# customer class membership requests
set n_not_yet_approved_plural [ec_decode $n_not_yet_approved 1 "" "s"]

set multiple_retailers_p [parameter::get -parameter MultipleRetailersPerProductP -default f]

set ec_system_name [ec_system_name]

if {$flush_db_cache} {
    db_flush_cache -cache_key_pattern "ec-*"
}
set title "Administration"
set context [list ]
