ad_page_contract {

    Main admin page for a single product.

    @author Alfred Werner (alfred@thunderstick.com)
    @creation-date Mar 2004

} {
    days_back:integer,optional
}

ad_require_permission [ad_conn package_id] admin



doc_body_append "
    [ad_admin_header "Search History"]

    <h2>Search History</h2>
    
    [ad_context_bar [list "../" "Ecommerce([ec_system_name])"]  "Search Results"]

    "

doc_body_append "<table><tr><th>Term</th><th>Count</th></tr>"
db_foreach search_summary "        SELECT count(search_text) as num_searches, search_text
        FROM ec_user_session_info
        WHERE search_text is not null and length(trim(search_text)) > 0
        GROUP BY search_text
        ORDER BY count(search_text) desc;
 " {


doc_body_append "
<tr>
  <td>
    $search_text
  </td>
  <td>
    $num_searches
  </td>
</tr>
"

}
doc_body_append "</table>"

doc_body_append [ad_admin_footer]
