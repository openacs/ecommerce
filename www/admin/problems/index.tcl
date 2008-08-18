ad_page_contract {

    This page dislpays the problems in the problem log, if display_all is
    not set then only unresolved problems are displayed.

    @author Jesse Koontz (jkoontz@arsdigita.com)
    @creation-date July 21, 1999
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @revision-date April 2002

} {
    display_all:optional
}

ad_require_permission [ad_conn package_id] admin

set title "Potential Problems"
set context [list $title]

set problem_count [db_string problem_count "
    select count(*) 
    from ec_problems_log"]
set unresolved_problem_count [db_string unresolved_count "
    select count(*) 
    from ec_problems_log where resolved_date is null"]

if { ![info exists display_all] } {
    set sql_clause [db_map include_resolved_date]
} else {
    set sql_clause ""
}

set problem_select_html ""
db_foreach problems_select "select l.*, u.first_names || ' ' || u.last_name as user_name
    from ec_problems_log l, cc_users u
    where l.resolved_by = u.user_id(+)
    $sql_clause
    order by problem_date asc" {

     append problem_select_html "<li>[util_AnsiDatetoPrettyDate $problem_date] ("

     if { ![empty_string_p $order_id] } {
         append problem_select_html "order #<a href=\"[ec_url_concat [ec_url] /admin]/orders/one?[export_url_vars order_id]\">$order_id</a> | "
     }

     if { [empty_string_p $resolved_date] } {
         append problem_select_html "<a href=\"resolve?[export_url_vars problem_id]\">mark resolved</a>"
     } else {
         append problem_select_html "resolved by [ec_admin_present_user $resolved_by $user_name] on [util_AnsiDatetoPrettyDate $resolved_date]"
     }

     append problem_select_html ") <p>$problem_details</p></li>"
}

