# /www/[ec_url_concat [ec_url] /admin]/cat/category-delete.tcl
ad_page_contract {

    @param category_id the ID of the category to delete
    @param category_name the name of the category to delete

    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    category_id:integer,notnull
    category_name:notnull
}

ad_require_permission [ad_conn package_id] admin

set title "Confirm Delete"
set context [list [list index "Product Categorization"] $title]

set export_form_vars_html [export_form_vars category_id]
