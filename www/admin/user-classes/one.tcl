#  www/[ec_url_concat [ec_url] /admin]/user-classes/one.tcl

ad_page_contract {
    @param user_class_id
    @param user_class_name
  @author
  @creation-date
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    user_class_id:naturalnum
    user_class_name
}

ad_require_permission [ad_conn package_id] admin

set page_html "[ad_admin_header "$user_class_name"]

<h2>$user_class_name</h2>

[ad_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index.tcl" "User Classes"] "One Class"]

<hr>

<ul>
<form method=post action=edit>
[export_form_vars user_class_id]
<li>Change user class name to: <input type=text name=user_class_name size=30 value=\"[ad_quotehtml $user_class_name]\">
<input type=submit value=\"Change\">
</form>

<li><a href=\"members?[export_url_vars user_class_id]\">View all members of this user class</a>

<p>

<li><a href=\"delete?[export_url_vars user_class_id user_class_name]\">Delete this user class</a>

<p>
"

# Set audit variables
# audit_name, audit_id, audit_id_column, return_url, audit_tables, main_tables
set audit_name "$user_class_name"
set audit_id $user_class_id
set audit_id_column "user_class_id"
set return_url "[ad_conn url]?[export_url_vars user_class_id user_class_name]"
set audit_tables [list ec_user_classes_audit]
set main_tables [list ec_user_classes]

append page_html "<li><a href=\"[ec_url_concat [ec_url] /admin]/audit?[export_url_vars audit_name audit_id audit_id_column return_url audit_tables main_tables]\">Audit Trail</a>

<p>

<li>Add a member to this user class.  Search for a member to add<br>

<form method=post action=member-add>
[export_form_vars user_class_id user_class_name]
By last name: <input type=text name=last_name size=30>
<input type=submit value=\"Search\">
</form>

<form method=post action=member-add>
[export_form_vars user_class_id user_class_name]
By email address: <input type=text name=email size=30>
<input type=submit value=\"Search\">
</form>

</ul>

[ad_admin_footer]
"



doc_return  200 text/html $page_html


