# add.tcl

ad_page_contract {
    @author
    @creation-date
    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
}

ad_require_permission [ad_conn package_id] admin

append doc_body "[ad_admin_header "Add Email Template"]
<h2>Add Email Template</h2>
[ad_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index.tcl" "Email Templates"] "New Template"]
<hr>
<p>
Please note: Email templates are designed be edited by a content writer (e.g. a customer service rep), but a programmer will have to schedule the sending of this email and program in the variable substitution.

<form method=post action=\"add-2\">

<h3>For informational purposes</h3>

<blockquote>
<table noborder>
<tr><td>Title</td><td><INPUT type=text name=title size=30></td></tr>
<tr><td>Variables</td><td><input type=text name=variables size=30> <a href=\"variables\">Note on variables</a></td></tr>
<tr><td>When Sent</td><td><textarea wrap=hard name=when_sent cols=50 rows=3></textarea></td></tr>
</table>
</blockquote>

<h3>Actually used when sending email</h3>

<blockquote>
<table noborder>
<tr><td>Subject Line</td><td><input type=text name=subject size=30></td></tr>
<tr><td valign=top>Message</td><td><TEXTAREA wrap=hard name=message COLS=50 ROWS=15></TEXTAREA></td></tr>
"



append doc_body "<tr><td valign=top>Issue Type*</td><td valign=top>[ec_issue_type_widget]</td></tr>
</table>
</blockquote>

<p>
<center>
<input type=submit value=\"Continue\">
</center>
</form>

* Note: A customer service issue is created whenever an email is sent. The issue is automatically closed unless the customer replies to the issue, in which case it is reopened.

[ad_admin_footer]
"

doc_return  200 text/html $doc_body
