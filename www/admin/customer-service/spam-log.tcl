# spam-log.tcl
ad_page_contract {
    @param  use_date_range_p:optional

    @author
    @creation-date
    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    start_date:array,date
    end_date:array,date
}

ad_require_permission [ad_conn package_id] admin

set title "Email Log"
set context [list [list index "Customer Service"] $title]

set form_alter_date_html "<form method=post action=\"[ad_conn url]\">
[ec_report_date_range_widget $start_date(date) $end_date(date)]
[export_form_vars use_date_range_p]<input type=submit value=\"Alter date range\"></form>"

set start $start_date(date)
set end $end_date(date)

set rows_to_return ""
db_foreach get_spam_people "select spam_text, mailing_list_category_id, mailing_list_subcategory_id, mailing_list_subsubcategory_id, user_class_id, product_id, to_char(last_visit_start_date,'YYYY-MM-DD HH24:MI:SS') as full_last_visit_start_date, to_char(last_visit_end_date,'YYYY-MM-DD HH24:MI:SS') as full_last_visit_end_date, to_char(spam_date,'YYYY-MM-DD HH24:MI:SS') as full_spam_date from ec_spam_log where (spam_date >= to_date('$start 00:00:00','YYYY-MM-DD HH24:MI:SS') and spam_date <= to_date('$end 23:59:59','YYYY-MM-DD HH24:MI:SS')) order by spam_date desc" {
    set members_description "All users"
    if { ![empty_string_p $mailing_list_category_id] } {
        set members_description "Members of the [ec_full_categorization_display $mailing_list_category_id $mailing_list_subcategory_id $mailing_list_subsubcategory_id] mailing list."
    }
    if { ![empty_string_p $user_class_id] } {
        set members_description "Members of the [db_string get_user_class_name "select user_class_name from ec_user_classes where user_class_id=:user_class_id"] user class."
    }
    if { ![empty_string_p $product_id] } {
        set members_description "Customers who purchased [db_string get_product_name "select product_name from ec_products where product_id=:product_id"] (product ID $product_id)."
    }
    if { ![empty_string_p $full_last_visit_start_date] } {
        set members_description "Users whose last visit to the site was between [ec_formatted_full_date $full_last_visit_start_date] and [ec_formatted_full_date $full_last_visit_end_date]."
    }
    append rows_to_return "<tr><td>[ec_formatted_full_date $full_spam_date]</td><td>${members_description}</td><td>[ec_display_as_html $spam_text]</td>"
}
