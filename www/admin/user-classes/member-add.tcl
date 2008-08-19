#  www/[ec_url_concat [ec_url] /admin]/user-classes/member-add.tcl
ad_page_contract {
    @param user_class_id
    @param user_class_name
    @param last_name:optional
    @param email:optional
  @author
  @creation-date
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    user_class_id:naturalnum
    user_class_name
    last_name:optional
    email:optional
}

ad_require_permission [ad_conn package_id] admin

set title "Add Member to $user_class_name"
set context [list [list index "User Classes"] $title]

if { [info exists last_name] } {
    set u_last_name %[string toupper $last_name]%
    append page_html "<h3>Users whose last name contains '$last_name':</h3>\n"
    set last_bit_of_query "upper(last_name) like :u_last_name"
    set last_name_search_p 1
} else {
    set l_email %[string tolower $email]%
    append page_html "<h3>Users whose email contains '$email':</h3>\n"
    set last_bit_of_query "email like :l_email"
    set last_name_search_p 0
}

set users_select_html ""
set users_count 0
db_foreach get_users_for_map "select user_id, first_names, last_name, email
    from cc_users
    where $last_bit_of_query" {

    append users_select_html "<li><a href=\"member-add-2?[export_url_vars user_id user_class_id user_class_name]\">$first_names $last_name</a> ($email)</li>\n"
    incr users_count
}
