
ad_page_contract {
    @param category_id the category of the item
    @param subcategory_id the id of the subcategory
    @param subsubcategory_id the id of the subcategory
    @param last_name:optional last name OR
    @param email:optional email 

    @cvs-id member-add.tcl,v 3.1.6.5 2000/09/22 01:34:56 kevin Exp
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    category_id
    subcategory_id
    subsubcategory_id
    last_name:optional
    email:optional
}

ad_require_permission [ad_conn package_id] admin

set page_html "[ad_admin_header "Add Member to this Mailing List"]

<h2>Add Member to this Mailing List</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index.tcl" "Mailing Lists"] "Add Member" ] 

<hr>
"


if { [info exists last_name] } {
    set u_last_name %[string toupper $last_name]%
    append page_html "<h3>Users whose last name contains '$last_name':</h3>\n"
    set last_bit_of_query "upper(last_name) like :u_last_name"
} else {
    set l_email %[string tolower $email]%
    append page_html "<h3>Users whose email contains '$email':</h3>\n"
    set last_bit_of_query "email like :l_email"
}

append page_html "<ul>
"

set user_counter 0
db_foreach get_user_info "
select user_id, first_names, last_name, email
  from cc_users
 where $last_bit_of_query
" {

    append page_html "<li><a href=\"member-add-2?[export_url_vars user_id category_id subcategory_id subsubcategory_id]\">$first_names $last_name</a> ($email)\n"
    incr user_counter
} 

if { $user_counter == 0 } {
    append page_html "No such users were found.\n</ul>\n"
} else {
    append page_html "</ul>\n<p>Click on a name to add them to the mailing list.\n"
}

db_release_unused_handles

append page_html "[ad_admin_footer]
"
doc_return  200 text/html $page_html

