#  www/[ec_url_concat [ec_url] /admin]/templates/index.tcl
ad_page_contract {

  @author
  @creation-date
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
}

ad_require_permission [ad_conn package_id] admin

set page_html "[ad_admin_header "Product Templates"]

<h2>Product Templates</h2>

[ad_context_bar [list "../" "Ecommerce([ec_system_name])"] "Product Templates"]

<hr>
<ul>
"

#
# A list of templates and their associated categories (if any)
#

set the_template_name ""
set the_template_id  ""
set the_categories   ""
proc maybe_write_a_template_line {} {
    uplevel {
	if [empty_string_p $the_template_name] { return }
	append page_html "<li><a href=\"one?template_id=$the_template_id\">$the_template_name</a> \n"
	regsub {, $} $the_categories {} the_categories
	if ![empty_string_p $the_categories] { append page_html "<br>associated with categories ($the_categories)" }
    }
}
db_foreach get_templates_info "
SELECT t.template_id, t.template_name, c.category_id, c.category_name
  FROM ec_templates t, ec_category_template_map m, ec_categories c
 WHERE t.template_id = m.template_id (+)
   and m.category_id = c.category_id (+)
  ORDER BY template_name, category_name" {

    if {[string compare $template_name $the_template_name] != 0} {
	maybe_write_a_template_line
	set the_template_name $template_name
	set the_template_id   $template_id
	set the_categories ""
    }
    if ![empty_string_p $category_name] {
	append the_categories "<a href=\"../cat/category?[export_url_vars category_id category_name]\">$category_name</a>, "
    }
}
maybe_write_a_template_line

# For audit tables
set table_names_and_id_column [list ec_templates ec_templates_audit template_id]

append page_html "
</ul>

<p>

<h3>Actions</h3>

<ul>

<li><a href=\"[ec_url_concat [ec_url] /admin]/audit-tables?[export_url_vars table_names_and_id_column]\">Audit All Templates</a>

<p>

<li><a href=\"add\">Add new template from scratch</a>
</ul>
[ad_admin_footer]
"




doc_return  200 text/html $page_html
