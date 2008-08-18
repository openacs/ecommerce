#  www/[ec_url_concat [ec_url] /admin]/templates/index.tcl
ad_page_contract {

  @author
  @creation-date
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
}

ad_require_permission [ad_conn package_id] admin

set title "Product Templates"
set context [list $title]

# A list of templates and their associated categories (if any)

set the_template_name ""
set the_template_id  ""
set the_categories   ""
set templates_info_html ""

db_foreach get_templates_info "
SELECT t.template_id, t.template_name, c.category_id, c.category_name
  FROM ec_templates t, ec_category_template_map m, ec_categories c
 WHERE t.template_id = m.template_id (+)
   and m.category_id = c.category_id (+)
  ORDER BY template_name, category_name" {

    if { [string compare $template_name $the_template_name] != 0 } {
        # 	maybe_write_a_template_line
        if { ![empty_string_p $the_template_name] } {
            append templates_info_html "<li><a href=\"one?template_id=$the_template_id\">$the_template_name</a> "
            regsub {, $} $the_categories {} the_categories
            if { ![empty_string_p $the_categories] } { 
                append templates_info_html "<br>associated with categories ($the_categories)</li>"
            } else {
                append templates_info_html "</li>"
            }
        }
    }

	set the_template_name $template_name
	set the_template_id   $template_id
	set the_categories ""
}
if { ![empty_string_p $category_name] } {
     append the_categories "<a href=\"../cat/category?[export_url_vars category_id category_name]\">$category_name</a>, "
}

# maybe_write_a_template_line
if { ![empty_string_p $the_template_name] } {
    append templates_info_html "<li><a href=\"one?template_id=$the_template_id\">$the_template_name</a> "
    regsub {, $} $the_categories {} the_categories
    if { ![empty_string_p $the_categories] } { 
        append templates_info_html "<br>associated with categories ($the_categories)</li>"
    } else {
        append templates_info_html "</li>"
    }
}

# For audit tables
set table_names_and_id_column [list ec_templates ec_templates_audit template_id]
set audit_url_html "[ec_url_concat [ec_url] /admin]/audit-tables?[export_url_vars table_names_and_id_column]"

