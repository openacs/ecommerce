# spam.tcl
ad_page_contract {
    @author
    @creation-date
    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    {start_date:date,optional}
    {end_date:date,optional}
}

ad_require_permission [ad_conn package_id] admin

set return_url "[ad_conn url]"

set customer_service_rep [ad_get_user_id]
if {$customer_service_rep == 0} {
    ad_returnredirect "/register.tcl?[export_url_vars return_url]"
    ad_script_abort
}
if { ![info exists start_date(date)] } {
    set start_date(date) "0"
    set end_date(date) "0"
}

set report_date_range_widget_html [ec_report_date_range_widget $start_date(date) $end_date(date)]

# this proc uses uplevel and assumes the existence of start_date and end_date
# or sets them if they do not exist
#ec_report_get_start_date_and_end_date
# only used here, so lets put the code here and get it working for now

# Get rid of leading zeroes in start%5fdate.day and
# end%5fdate.day because it can't interpret 08 and
# 09 (It thinks they're octal numbers)
if { [info exists "start%5fdate.day"] } {
    set "start%5fdate.day" [string trimleft [set "start%5fdate.day"] "0"]
    set "end%5fdate.day" [string trimleft [set "end%5fdate.day"] "0"]
    ns_set update $form "start%5fdate.day" [set start%5fdate.day]
    ns_set update $form "end%5fdate.day" [set end%5fdate.day]
}

set current_year [ns_fmttime [ns_time] "%Y"]
set current_month [ns_fmttime [ns_time] "%m"]
set current_date [ns_fmttime [ns_time] "%d"]

# If there's no time connected to the date, just the date argument to ns_dbformvalue,
# otherwise use the datetime argument
if [catch { ns_dbformvalue [ns_conn form] start_date date start_date} errmsg ] {
    if { ![info exists return_date_error_p] || $return_date_error_p == "f" } {
        set start_date(date) "$current_year-$current_month-01"
    } else {
        set start_date(date) "0"
    }    
}
if [catch  { ns_dbformvalue [ns_conn form] end_date date end_date} errmsg ] {
    if { ![info exists return_date_error_p] || $return_date_error_p == "f" } {
        set end_date(date) "$current_year-$current_month-$current_date"
    } else {
        set end_date(date) "0"
    }
}
if { [string compare $start_date(date) ""] == 0 } {
    if { ![info exists return_date_error_p] || $return_date_error_p == "f" } {
        set start_date(date) "$current_year-$current_month-01"
    } else {
        set start_date(date) "0"
    }
}
if { [string compare $end_date(date) ""] == 0 } {
    if { ![info exists return_date_error_p] || $return_date_error_p == "f" } {
        set end_date(date) "$current_year-$current_month-$current_date"
    } else {
        set end_date(date) "0"
    }
}


set title  "Spam Users"
set context [list [list index "Customer Service"] $title]



set mailing_list_widget  [ec_mailing_list_widget]
set user_class_widget    [ec_user_class_widget]
set only_category_widget [ec_only_category_widget]

foreach {v name widget} [list ml_body {Mailing lists} $mailing_list_widget uc_body {User classes} $user_class_widget c_body {Category} $only_category_widget] {
    if {[string equal [string trim $widget] "<b>none</b>"]} {
        set $v  "$name: $widget - No one to spam.\n"
    } else {
        set $v "<form method=post action=spam-2>
<p>$name: $widget <br><input type=checkbox name=show_users_p value=\"t\" checked>Show me the users who will be spammed.</p>
 <center><input type=submit value=\"Continue\"></center></form>\n"        
    }
}

set report_date_range_widget_html [ec_report_date_range_widget $start_date(date) $end_date(date)]
