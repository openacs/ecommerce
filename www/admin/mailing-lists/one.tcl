# one.tcl

ad_page_contract {
    @author
    @creation-date
    @cvs-id one.tcl,v 3.1.6.6 2000/09/22 01:34:57 kevin Exp
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


append doc_body "[ad_admin_header "$mailing_list_name"]

<h2>$mailing_list_name</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index.tcl" "Mailing Lists"] "One Mailing List"]

<hr>
<h3>Members</h3>
<ul>
"

set user_query "select u.user_id, first_names, last_name
    from cc_users u, ec_cat_mailing_lists m
    where u.user_id=m.user_id
    "

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

db_foreach get_user_info $sql {
    
    append doc_body "<li><a href=\"[ec_acs_admin_url]users/one?user_id=$user_id\">$first_names $last_name</a> \[<a href=\"member-remove?[export_url_vars category_id subcategory_id subsubcategory_id user_id]\">remove</a>\]"
} if_no_rows {
    append doc_body "None"
}

db_release_unused_handles

append doc_body "</ul>

<h3>Add a Member</h3>

<form method=post action=member-add>
[export_form_vars category_id subcategory_id subsubcategory_id]
By last name: <input type=text name=last_name size=30>
<input type=submit value=\"Search\">
</form>

<form method=post action=member-add>
[export_form_vars category_id subcategory_id subsubcategory_id]
By email address: <input type=text name=email size=30>
<input type=submit value=\"Search\">
</form>

[ad_admin_footer]
"



doc_return  200 text/html $doc_body

