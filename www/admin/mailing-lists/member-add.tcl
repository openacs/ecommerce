ad_page_contract {
    @param category_id the category of the item
    @param subcategory_id the id of the subcategory
    @param subsubcategory_id the id of the subcategory
    @param last_name:optional last name OR
    @param email:optional email 

    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    category_id
    subcategory_id
    subsubcategory_id
    last_name:optional
    email:optional
}

ad_require_permission [ad_conn package_id] admin

set title "Add Member to this Mailing List"
set context [list [list index "Mailing Lists"] $title]

if { [info exists last_name] } {
    set u_last_name %[string toupper $last_name]%
    set last_bit_of_query "upper(last_name) like :u_last_name"
    set last_name_p 1
} else {
    set l_email %[string tolower $email]%
    set last_bit_of_query "email like :l_email"
    set last_name_p 0
}

set user_counter 0
set user_info_html ""
db_foreach get_user_info "select user_id, first_names, last_name, email
  from cc_users
 where $last_bit_of_query" {
    append user_info_html "<li><a href=\"member-add-2?[export_url_vars user_id category_id subcategory_id subsubcategory_id]\">$first_names $last_name</a> ($email)</li>\n"
    incr user_counter
} 

db_release_unused_handles
