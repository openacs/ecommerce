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

db_1row get_template_data "
select template_name, template
  from ec_templates
  where template_id=:template_id
"

set page_html "[ad_admin_header "Associate with a Category"]

<h2>Associate with a Category</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index.tcl" "Product Templates"] [list "one.tcl?template_id=$template_id" "$template_name"] "Associate with a Category"]

<hr> 

The point of doing this is just to make it a little faster when
you are adding new products.  It is completely optional.

<p>

If you associate this template with a product category, then whenever
you add a new product of that category, the product will by default be
set to display with this template, although you can always change it.
(However, if you add a new product and put it in more than one
category, then this template might not end up being the default for
that product.)

<p>

This template may be associated with as many categories as you like.
"
# see if it's already associated with any categories

set n_categories_associated_with [db_string get_n_category_assocs "
select count(*)
  from ec_category_template_map
 where template_id=:template_id
"]

if { $n_categories_associated_with > 0 } {
    append page_html "Currently this template is associated with the category(ies):\n<ul>\n"
  
    db_foreach get_each_template_assoc "
    select m.category_id, c.category_name
      from ec_category_template_map m, ec_categories c
     where m.category_id = c.category_id
       and m.template_id = :template_id
    " {

	append page_html "<li>$category_name\n"
    }

    append page_html "</ul>\n"

} else {
    append page_html " This template has not yet been associated with any categories."
}

# see if there are any categories left to associate it with
set n_categories_left [db_string get_n_left "
select count(*)
  from ec_categories
 where category_id not in (select category_id
                             from ec_category_template_map
                            where template_id=:template_id)
"]

if { $n_categories_left == 0 } {
    append page_html "All categories are associated with this template.  There are none left to add!"
} else {

    append page_html "
    <form method=post action=category-associate-2>
    [export_form_vars template_id]
    
    Category: 
    <select name=category_id>
    "
    
    db_foreach get_remaining_categories "
    select category_id, category_name
      from ec_categories
     where category_id not in (select category_id
                                 from ec_category_template_map
                                where template_id=:template_id)
    " {

	append page_html "<option value=\"$category_id\">$category_name\n"
    }
    
    append page_html "
    </select>
    <input type=submit value=\"Associate\">
    </form>
    "
}

append page_html [ad_admin_footer]

doc_return  200 text/html $page_html
