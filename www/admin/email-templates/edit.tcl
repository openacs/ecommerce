# edit.tcl

ad_page_contract {
    @param  email_template_id
    @author
    @creation-date
    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    email_template_id
}

ad_require_permission [ad_conn package_id] admin

append doc_body "[ad_admin_header "Edit Email Template"]
<h2>Edit Email Template</h2>
[ad_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index.tcl" "Email Templates"] "Edit Template"]
<hr>
<form method=post action=\"edit-2\">
[export_form_vars email_template_id]
"


if { ![db_0or1row unused "select * from ec_email_templates where email_template_id=:email_template_id"] } {
    ad_return_complaint 1 "Invalid email_template_id passed in"
}

db_release_unused_handles

append doc_body "<h3>For informational purposes</h3>
<blockquote>
<table noborder>
<tr><td>Title</td><td><INPUT type=text name=title size=30 value=\"[ad_quotehtml $title]\"></td></tr>
<tr><td>Variables</td><td><input type=text name=variables size=30 value=\"[ad_quotehtml $variables]\"> <a href=\"variables\">Note on variables</a></td></tr>
<tr><td>When Sent</td><td><textarea wrap=hard name=when_sent cols=50 rows=3>$when_sent</textarea></td></tr>
</table>
</blockquote>

<h3>Actually used when sending email</h3>

<blockquote>
<table noborder>
<tr><td>Template ID</td><td>$email_template_id</td></tr>
<tr><td>Subject Line</td><td><input type=text name=subject size=30 value=\"[ad_quotehtml $subject]\"></td></tr>
<tr><td valign=top>Message</td><td><TEXTAREA wrap=hard name=message COLS=50 ROWS=15>$message</TEXTAREA></td></tr>
<tr><td valign=top>Issue Type*</td><td valign=top>[ec_issue_type_widget $issue_type_list]</td></tr>
</table>
</blockquote>
<p>
<center>
<input type=submit value=\"Continue\">
</center>
</form>

* Note: A customer service issue is created whenever an email is sent. The issue is automatically closed unless the customer replies to the issue, in which case it is reopened.
"

set table_names_and_id_column [list ec_email_templates ec_email_templates_audit email_template_id]

# Set audit variables
# audit_id_column, return_url, audit_tables, main_tables
set audit_id_column "email_template_id"
set return_url "[ad_conn url]?[export_entire_form_as_url_vars]"
set audit_tables [list ec_email_templates_audit]
set main_tables [list ec_email_templates]
set audit_name "Email Template: $title"
set audit_id $email_template_id

append doc_body "<p>
\[<a href=\"[ec_url_concat [ec_url] /admin]/audit?[export_url_vars audit_name audit_id audit_id_column return_url audit_tables main_tables]\">Audit Trail</a>\]

[ad_admin_footer]
"


doc_return  200 text/html $doc_body
