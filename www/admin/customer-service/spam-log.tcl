# spam-log.tcl

ad_page_contract {
    @param  use_date_range_p:optional

    @author
    @creation-date
    @cvs-id spam-log.tcl,v 3.0.12.6 2000/09/22 01:34:54 kevin Exp
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    use_date_range_p:optional
    start_date:array,date
    end_date:array,date
}

ad_require_permission [ad_conn package_id] admin

if { $use_date_range_p == "t" } {
    set start_date $start_date(date)
    set end_date $end_date(date)
}


proc spam_to_summary { mailing_list_category_id mailing_list_subcategory_id mailing_list_subsubcategory_id user_class_id product_id full_last_visit_start_date full_last_visit_end_date } {
    if { ![empty_string_p $mailing_list_category_id] } {
	return "Members of the [ec_full_categorization_display $mailing_list_category_id $mailing_list_subcategory_id $mailing_list_subsubcategory_id] mailing list."
    }
    if { ![empty_string_p $user_class_id] } {
	return "Members of the [db_string get_user_class_name "select user_class_name from ec_user_classes where user_class_id=:user_class_id"] user class."
    }
    if { ![empty_string_p $product_id] } {
	return "Customers who purchased [db_string get_product_name "select product_name from ec_products where product_id=:product_id"] (product ID $product_id)."
    }
    if { ![empty_string_p $full_last_visit_start_date] } {
	return "Users whose last visit to the site was between [ec_formatted_full_date $full_last_visit_start_date] and [ec_formatted_full_date $full_last_visit_end_date]."
    }
}



append doc_body "[ad_admin_header "Spam Log"]
<h2>Spam Log</h2>
[ad_admin_context_bar [list "../index" "Ecommerce([ec_system_name])"] [list "index" "Customer Service Administration"] [list "spam" "Spam Users"] "Spam Log"]

<hr>
"

ec_report_get_start_date_and_end_date

set date_part_of_query "(spam_date >= to_date('$start_date 00:00:00','YYYY-MM-DD HH24:MI:SS') and spam_date <= to_date('$end_date 23:59:59','YYYY-MM-DD HH24:MI:SS'))"
set user_date_range_p "t"
append doc_body "<form method=post action=\"[ad_conn url]\">
[ec_report_date_range_widget $start_date $end_date]

[export_form_vars use_date_range_p]
<input type=submit value=\"Alter date range\">
</form>

<table border>
<tr><th>Date</th><th>To</th><th>Text</th></tr>
"

set sql "select spam_text, mailing_list_category_id, mailing_list_subcategory_id, mailing_list_subsubcategory_id, user_class_id, product_id, to_char(last_visit_start_date,'YYYY-MM-DD HH24:MI:SS') as full_last_visit_start_date, to_char(last_visit_end_date,'YYYY-MM-DD HH24:MI:SS') as full_last_visit_end_date, to_char(spam_date,'YYYY-MM-DD HH24:MI:SS') as full_spam_date from ec_spam_log where $date_part_of_query order by spam_date desc"

set rows_to_return ""
db_foreach get_spam_people $sql {
    
    append rows_to_return "<tr><td>[ec_formatted_full_date $full_spam_date]</td><td>[spam_to_summary_sub $mailing_list_category_id $mailing_list_subcategory_id $mailing_list_subsubcategory_id $user_class_id $product_id $full_last_visit_start_date $full_last_visit_end_date]</td><td>[ec_display_as_html $spam_text]</td>"
}

append doc_body "$rows_to_return
</table>

[ad_admin_footer]
"


doc_return  200 text/html $doc_body