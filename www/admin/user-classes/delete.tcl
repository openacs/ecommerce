#  www/[ec_url_concat [ec_url] /admin]/user-classes/delete.tcl
ad_page_contract {
    @param  user_class_id
  @author
  @creation-date
  @cvs-id delete.tcl,v 3.1.6.5 2000/09/22 01:35:06 kevin Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    user_class_id:naturalnum
}

ad_require_permission [ad_conn package_id] admin

set user_class_name [db_string get_ucname "select user_class_name from ec_user_classes where user_class_id=:user_class_id"]



set page_html "[ad_admin_header "Delete $user_class_name"]

<h2>Delete $user_class_name</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index.tcl" "User Classes"] [list "one.tcl?[export_url_vars user_class_name user_class_id]" $user_class_name] "Delete User Class"]

<hr>
Please confirm that you wish to delete this user class.  Note that this will leave any users who are currently in this class (if any) classless.

<p>

<center>
<form method=post action=delete-2>
[export_form_vars user_class_id]
<input type=submit value=\"Confirm\">
</form>
</center>

[ad_admin_footer]
"


doc_return  200 text/html $page_html

