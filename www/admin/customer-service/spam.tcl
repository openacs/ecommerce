# spam.tcl
ad_page_contract {
    @author
    @creation-date
    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
}

ad_require_permission [ad_conn package_id] admin

set return_url "[ad_conn url]"

set customer_service_rep [ad_get_user_id]
if {$customer_service_rep == 0} {
    ad_returnredirect "/register.tcl?[export_url_vars return_url]"
    ad_script_abort
}

# this proc uses uplevel and assumes the existence of start_date and end_date
# or sets them if they do not exist
ec_report_get_start_date_and_end_date

set title  "Spam Users"
set context [list [list index "Customer Service"] $title]

set report_date_range_widget_html [ec_report_date_range_widget $start_date(date) $end_date(date)]

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
