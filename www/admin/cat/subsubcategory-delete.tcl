# /www/[ec_url_concat [ec_url] /admin]/cat/subsubcategory-delete.tcl
ad_page_contract {

    Confirmation page for deleting an ecommerce product subsubcategory.

    @param category_id the category ID
    @param category_name the category name
    @param subcategory_id the subcategory ID
    @param subcategory_name the subcategory name
    @param subsubcategory_id sub sub category to delete
    @param subsubcategory_name name of sub sub to delete

    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    category_id:integer,notnull
    category_name:notnull
    subcategory_id:integer,notnull
    subcategory_name:notnull
    subsubcategory_id:integer,notnull
    subsubcategory_name:notnull
}

ad_require_permission [ad_conn package_id] admin
 
set title "Confirm Deletion"
set context [list [list index "Product Categorization"] $title]

set export_form_vars_html [export_form_vars subsubcategory_id subcategory_id subcategory_name category_id category_name]
