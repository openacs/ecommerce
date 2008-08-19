# one.tcl
ad_page_contract {
    @author
    @creation-date
    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} { 
    category_id:optional
    subcategory_id:optional
    subsubcategory_id:optional

    categorization:optional
}

ad_require_permission [ad_conn package_id] admin

if { [info exists categorization] } {
    catch { set category_id [lindex $categorization 0] }
    catch { set subcategory_id [lindex $categorization 1] }
    catch { set subsubcategory_id [lindex $categorization 2] }
}

# now we're left with category_id, subcategory_id, and/or subsubcategory_id
# regardless of how we got here
if { ![info exists category_id] } {
    set category_id ""
}
if { ![info exists subcategory_id] } {
    set subcategory_id ""
}
if { ![info exists subsubcategory_id] } {
    set subsubcategory_id ""
}

set mailing_list_name [ec_full_categorization_display $category_id $subcategory_id $subsubcategory_id]

set title "List ${mailing_list_name}"
set context [list [list index "Mailing Lists"] $title]

set user_query "select u.user_id, first_names, last_name
    from cc_users u, ec_cat_mailing_lists m
    where u.user_id=m.user_id"

if { ![empty_string_p $subsubcategory_id] } {
    append user_query "and m.subsubcategory_id=$subsubcategory_id"
} elseif { ![empty_string_p $subcategory_id] } {
    append user_query "and m.subcategory_id=$subcategory_id
    and m.subsubcategory_id is null"
} elseif { ![empty_string_p $category_id] } {
    append user_query "and m.category_id=$category_id
    and m.subcategory_id is null"
} else {
    append user_query "and m.category_id is null"
}

set sql $user_query
set users_count 0
set user_info_html
db_foreach get_user_info $sql {
    incr users_count
    append user_info_html "<li><a href=\"[ec_acs_admin_url]users/one?user_id=$user_id\">$first_names $last_name</a> \[<a href=\"member-remove?[export_url_vars category_id subcategory_id subsubcategory_id user_id]\">remove</a>\]</li>"
} 

set export_form_vars_html [export_form_vars category_id subcategory_id subsubcategory_id]
db_release_unused_handles
