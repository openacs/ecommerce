# user-identification-search.tcl

ad_page_contract {
    @param keyword
    @author
    @creation-date
    @cvs-id user-identification-search.tcl,v 3.0.12.4 2000/09/22 01:34:54 kevin Exp
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    keyword
} 

ad_require_permission [ad_conn package_id] admin

set page_title "Unregistered User Search"


append doc_body "[ad_admin_header $page_title]
<h2>$page_title</h2>

[ad_admin_context_bar [list "../index.tcl" "Ecommerce([ec_system_name])"] [list "index.tcl" "Customer Service Administration"] $page_title]

<hr>
<ul>
"



# keyword can refer to email, first_names, last_name, postal_code, or other_id_info
set keyword [string tolower $keyword]
set sql "select user_identification_id from ec_user_identification
where (email like :keyword or lower(first_names || ' ' || last_name) like :keyword or lower(postal_code) like :keyword or lower(other_id_info) like :keyword)
and user_id is null
"

set user_counter 0
db_foreach search_for_users_like_kw  $sql {
    incr user_counter
    
    append doc_body "<li>[ec_user_identification_summary_sub $user_identification_id]"
}

if { $user_counter == 0 } {
    append doc_body "No users found."
}

append doc_body "</ul>
[ad_admin_footer]
"



doc_return  200 text/html $doc_body



