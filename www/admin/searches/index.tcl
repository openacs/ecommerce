ad_page_contract {

    Search history

    @author Alfred Werner (alfred@thunderstick.com)
    @creation-date Mar 2004

} {
    days_back:integer,optional
}

ad_require_permission [ad_conn package_id] admin

set title "Search History"
set context [list $title]

set search_summary_html ""
db_foreach search_summary "SELECT count(search_text) as num_searches, search_text
        FROM ec_user_session_info
        WHERE search_text is not null and length(trim(search_text)) > 0
        GROUP BY search_text
        ORDER BY count(search_text) desc" {

        append search_summary_html "<tr><td>$search_text</td><td>$num_searches</td></tr>\n"
}

