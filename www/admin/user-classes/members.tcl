#  www/[ec_url_concat [ec_url] /admin]/user-classes/members.tcl
ad_page_contract {
    @param user_class_id
  @author
  @creation-date
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    user_class_id:notnull
}

ad_require_permission [ad_conn package_id] admin

set user_class_name [db_string get_uc_name "select user_class_name from ec_user_classes where user_class_id = :user_class_id"]

set title "Members of $user_class_name"
set context [list [list index "User Classes"] $title]

set requires_approval_p [parameter::get -package_id [ec_id] -parameter UserClassApproveP -default 1]

set users_count 0
set users_in_ec_user_class_html ""
db_foreach get_users_in_ec_user_class "select 
cc.user_id, first_names, last_name, email,
m.user_class_approved_p
from cc_users cc, ec_user_class_user_map m
where cc.user_id = m.user_id
and m.user_class_id=:user_class_id" {
    incr users_count
    append users_in_ec_user_class_html "<li><a href=\"[ec_acs_admin_url]users/one?user_id=$user_id\">$first_names $last_name</a> ($email) "
    if { $requires_approval_p } {
	    append users_in_ec_user_class_html "[ec_decode $user_class_approved_p "t" "" "un"]approved "
    }
    append users_in_ec_user_class_html "(<a href=\"member-delete?[export_url_vars user_class_name user_class_id user_id]\">remove</a>"
    if { $requires_approval_p } {
	    if { $user_class_approved_p == "t" } {
	        append users_in_ec_user_class_html " | <a href=\"approve-toggle?[export_url_vars user_class_id user_id user_class_approved_p]\">unapprove</a>"
	    } else {
	        append users_in_ec_user_class_html " | <a href=\"approve-toggle?[export_url_vars user_class_id user_id user_class_approved_p]\">approve</a>"
	    }
    }
    append users_in_ec_user_class_html ")</li>\n"
} 
