ad_page_contract {
    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
}

ad_require_permission [ad_conn package_id] admin

set page_html "[ad_admin_header "Mailing Lists"]

<h2>Mailing Lists</h2>

[ad_context_bar [list "../" "Ecommerce([ec_system_name])"] "Mailing Lists"]

<hr>

<h3>Mailing Lists with Users</h3>
"



append page_html "[ec_mailing_list_widget "f"]

<h3>All Mailing Lists</h3>

<blockquote>
<form method=post action=one>

[ec_category_widget]
<input type=submit value=\"Go\">
</form>

</blockquote>

[ad_admin_footer]
"
doc_return  200 text/html $page_html
