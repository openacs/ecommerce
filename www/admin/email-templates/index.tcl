# index.tcl

ad_page_contract {
    @author
    @creation-date
    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
}

ad_require_permission [ad_conn package_id] admin

set table_names_and_id_column [list ec_email_templates ec_email_templates_audit email_template_id]

append doc_body "[ad_admin_header "Email Templates"]
<h2>Email Templates</h2>
[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] "Email Templates"]
<hr><p>
<ul>
<li><A href=\"add\">New Email Template</a>
<p>
<li><a href=\"[ec_url_concat [ec_url] /admin]/audit-tables?[export_url_vars table_names_and_id_column]\">Audit All Email Templates</a>
</ul>
<p>
<b>Current Email Templates:</b>
<ul>
"


set sql "select title, email_template_id from ec_email_templates order by title"

db_foreach get_email_templates $sql {
    
    append doc_body "<li> <a href=\"edit?email_template_id=$email_template_id\">$title</a> \n"
}

db_release_unused_handles

append doc_body "</ul>
[ad_admin_footer]"

doc_return  200 text/html $doc_body
