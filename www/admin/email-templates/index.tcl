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

set title "Email Templates"
set context [list $title]

set audit_url_html "[ec_url_concat [ec_url] /admin]/audit-tables?[export_url_vars table_names_and_id_column]"

set sql "select title, email_template_id from ec_email_templates order by title"
set email_templates_html ""
db_foreach get_email_templates $sql {
    append email_templates_html "<li> <a href=\"edit?email_template_id=$email_template_id\">$title</a></li>\n"
}

db_release_unused_handles

