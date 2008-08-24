# user-identification-search.tcl
ad_page_contract {
    @param keyword
    @author
    @creation-date
    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    keyword
} 

ad_require_permission [ad_conn package_id] admin

set title "Unregistered User Search"
set context [list [list index "Customer Service"] $title]

# keyword can refer to email, first_names, last_name, postal_code, or other_id_info
set keyword [string tolower $keyword]
set sql "select user_identification_id from ec_user_identification
where (email like :keyword or lower(first_names || ' ' || last_name) like :keyword or lower(postal_code) like :keyword or lower(other_id_info) like :keyword)
and user_id is null"

set user_counter 0
set users_like_kw_html ""
db_foreach search_for_users_like_kw  $sql {
    incr user_counter
    append users_like_kw_html "<li>[ec_user_identification_summary_sub $user_identification_id]</li>"
}

