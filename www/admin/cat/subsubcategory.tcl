# /www/[ec_url_concat [ec_url] /admin]/cat/subsubcategory.tcl
ad_page_contract {

    Displays properties of given ecommerce product subsubcategory.

    @param category_id the category ID
    @param category_name the category name
    @param subcategory_id the subcategory ID
    @param subcategory_name the subcategory name
    @param subsubcategory_name the subsubcategory new name
    @param subsubcategory_id the subsubcategory ID

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

set title "Subsubcategory: ${subsubcategory_name}"
set context [list [list index "Product Categorization"] $title]

# Set audit variables
# audit_name, audit_id, audit_id_column, return_url, audit_tables, main_tables
set audit_name "$subsubcategory_name"
set audit_id $subsubcategory_id
set audit_id_column "subsubcategory_id"
set return_url "subsubcategory?[export_url_vars subsubcategory_id subsubcategory_name]"
set audit_tables [list ec_subsubcategories_audit ec_subsubcat_prod_map_audit]
set main_tables [list ec_subsubcategories ec_subsubcategory_product_map]

set audit_url_html [ec_url_concat [ec_url] /admin]/audit?[export_url_vars audit_name audit_id audit_id_column return_url audit_tables main_tables]

set export_form_vars_html [export_form_vars category_id category_name subcategory_id subcategory_name subsubcategory_id]
set export_form_vars_css_html [export_url_vars category_id category_name subcategory_id subcategory_name subsubcategory_id subsubcategory_name]
