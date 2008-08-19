#  www/[ec_url_concat [ec_url] /admin]/templates/category-associate.tcl
ad_page_contract {
  @param template
  @author
  @creation-date
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    template_id:integer
}

ad_require_permission [ad_conn package_id] admin

db_1row get_template_data "select template_name, template
  from ec_templates
  where template_id=:template_id"

set title "Associate with a Category"
set context [list [list index "Product Templates"] $title]

# see if it's already associated with any categories
set n_categories_associated_with [db_string get_n_category_assocs "select count(*)
  from ec_category_template_map
 where template_id=:template_id"]


set template_associations_html ""
if { $n_categories_associated_with > 0 } {
    db_foreach get_each_template_assoc "
    select m.category_id, c.category_name
      from ec_category_template_map m, ec_categories c
     where m.category_id = c.category_id
       and m.template_id = :template_id" {
        append template_associations_html "<li>$category_name</li>"
    }
} 

# see if there are any categories left to associate it with
set n_categories_left [db_string get_n_left "select count(*)
  from ec_categories
 where category_id not in (select category_id
                             from ec_category_template_map
                            where template_id=:template_id)"]

if { $n_categories_left > 0 } {

    set export_form_vars_html [export_form_vars template_id]
    set remainging_categories_html ""
    db_foreach get_remaining_categories "select category_id, category_name
      from ec_categories
     where category_id not in (select category_id
                                 from ec_category_template_map
                                where template_id=:template_id)" {
        append remaining_categories_html "<option value=\"$category_id\">$category_name</option>"
    }
}
