#  www/[ec_url_concat [ec_url] /admin]/templates/edit.tcl
ad_page_contract {
    @param template_id
  @author
  @creation-date
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    template_id:integer
}

ad_require_permission [ad_conn package_id] admin

db_1row get_template_info "select template_name, template from ec_templates where template_id=:template_id"


set page_html "[ad_admin_header "Edit Template"]

<h2>Edit Template</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index.tcl" "Product Templates"] [list "one.tcl?template_id=$template_id" "$template_name"] "Edit Template"]

<hr>

<form method=post action=edit-2>
[export_form_vars template_id]

Name: <input type=text name=template_name size=30 value=\"[ad_quotehtml $template_name]\">

<p>

ADP template:<br>
<textarea name=template rows=30 cols=60>$template</textarea>

<p>

<center>
<input type=submit value=\"Submit Changes\">
</center>

</form>

[ad_admin_footer]
"
db_release_unused_handles
doc_return  200 text/html $page_html
