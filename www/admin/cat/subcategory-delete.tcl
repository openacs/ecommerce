#  www/[ec_url_concat [ec_url] /admin]/cat/subcategory-delete.tcl
ad_page_contract {

    Confirmation page for deleting an ecommerce product subcategory.

    @param category_id the ID of the category
    @param category_name the name of the category
    @param subcategory_id the ID of the subcategory
    @param subcategory_name the ID of the subcategory

    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    category_id:integer,notnull
    category_name:notnull
    subcategory_id:integer,notnull
    subcategory_name:notnull
}

ad_require_permission [ad_conn package_id] admin

set title "Confirm Deletion"
set context [list [list index "Product Categorization"] $title]

set export_form_vars_html [export_form_vars subcategory_id category_id category_name]

