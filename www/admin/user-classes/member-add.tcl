#  www/[ec_url_concat [ec_url] /admin]/user-classes/member-add.tcl
ad_page_contract {
    @param user_class_id
    @param user_class_name
    @param last_name:optional
    @param email:optional
  @author
  @creation-date
  @cvs-id member-add.tcl,v 3.1.6.6 2000/09/22 01:35:06 kevin Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    user_class_id:naturalnum
    user_class_name
    last_name:optional
    email:optional
}

ad_require_permission [ad_conn package_id] admin

set page_html "[ad_admin_header "Add Member to $user_class_name"]

<h2>Add Member to $user_class_name</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index.tcl" "User Classes"] [list "one.tcl?[export_url_vars user_class_id user_class_name]" $user_class_name] "Add Member" ] 

<hr>
"

if { [info exists last_name] } {
    set u_last_name %[string toupper $last_name]%
    append page_html "<h3>Users whose last name contains '$last_name':</h3>\n"
    set last_bit_of_query "upper(last_name) like :u_last_name"
} else {
 set u_email %[string toupper $email]%
    append page_html "<h3>Users whose email contains '$email':</h3>\n"
    set last_bit_of_query "upper(email) like :u_email"
}

append page_html "<ul>
"


db_foreach get_users_for_map "select user_id, first_names, last_name, email
from cc_users
where $last_bit_of_query" {


    append page_html "<li><a href=\"member-add-2?[export_url_vars user_id user_class_id user_class_name]\">$first_names $last_name</a> ($email)\n"

} if_no_rows {
    append page_html "No such users were found.\n</ul>\n"
}

append page_html "</ul>\n<p>Click on a name to add that user to $user_class_name.\n"


append page_html "[ad_admin_footer]
"


doc_return  200 text/html $page_html