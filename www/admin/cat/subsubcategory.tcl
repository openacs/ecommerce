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

set page_html "[ad_admin_header "Subsubcategory: $subsubcategory_name"]

<h2>Subsubcategory: $subsubcategory_name</h2>

[ad_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index" "Categories &amp; Subcategories"] [list "category?[export_url_vars category_id category_name]" $category_name] [list "subcategory?[export_url_vars category_id category_name subcategory_id subcategory_name]" $subcategory_name] "One Subsubcategory"]

<hr>

<ul>

<form method=post action=subsubcategory-edit>
[export_form_vars category_id category_name subcategory_id subcategory_name subsubcategory_id]
<li>Change subsubcategory name to:
<input type=text name=subsubcategory_name size=30 value=\"[ad_quotehtml $subsubcategory_name]\">
<input type=submit value=\"Change\">
</form>

<p>

<li><a href=\"../products/one-subsubcategory?[export_url_vars category_id category_name subcategory_id subcategory_name subsubcategory_id subsubcategory_name]\">View all products in this subsubcategory</a>

<p>

<li><a href=\"subsubcategory-delete?[export_url_vars category_id category_name subcategory_id subcategory_name subsubcategory_id subsubcategory_name]\">Delete this subsubcategory</a>

<p>
"

# Set audit variables
# audit_name, audit_id, audit_id_column, return_url, audit_tables, main_tables
set audit_name "$subsubcategory_name"
set audit_id $subsubcategory_id
set audit_id_column "subsubcategory_id"
set return_url "subsubcategory?[export_url_vars subsubcategory_id subsubcategory_name]"
set audit_tables [list ec_subsubcategories_audit ec_subsubcat_prod_map_audit]
set main_tables [list ec_subsubcategories ec_subsubcategory_product_map]

append page_html "<li><a href=\"[ec_url_concat [ec_url] /admin]/audit?[export_url_vars audit_name audit_id audit_id_column return_url audit_tables main_tables]\">Audit Trail</a>

</ul>

[ad_admin_footer]
"
doc_return  200 text/html $page_html

