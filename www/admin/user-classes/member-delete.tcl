#  www/[ec_url_concat [ec_url] /admin]/user-classes/member-delete.tcl
ad_page_contract {
    @param user_class_id
    @param user_class_name
    @param user_id
  @author
  @creation-date
  @cvs-id member-delete.tcl,v 3.2.6.4 2000/09/22 01:35:06 kevin Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    user_class_id:naturalnum
    user_class_name
    user_id:naturalnum
}

ad_require_permission [ad_conn package_id] admin

set page_html "[ad_admin_header "Remove Member from $user_class_name"]

<h2>Remove Member from $user_class_name</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index.tcl" "User Classes"] [list "one.tcl?[export_url_vars user_class_id user_class_name]" $user_class_name] "Members" ] 

<hr>

Please confirm that you wish to remove this member from $user_class_name.

<center>
<form method=post action=member-delete-2>
[export_form_vars user_class_id user_class_name user_id]
<input type=submit value=\"Confirm\">
</form>
</center>

[ad_admin_footer]
"

doc_return  200 text/html $page_html
