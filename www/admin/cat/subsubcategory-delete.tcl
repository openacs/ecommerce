# /www/[ec_url_concat [ec_url] /admin]/cat/subsubcategory-delete.tcl
ad_page_contract {

    Confirmation page for deleting an ecommerce product subsubcategory.

    @param category_id the category ID
    @param category_name the category name
    @param subcategory_id the subcategory ID
    @param subcategory_name the subcategory name
    @param subsubcategory_id sub sub category to delete
    @param subsubcategory_name name of sub sub to delete

    @cvs-id subsubcategory-delete.tcl,v 3.1.6.3 2000/09/22 01:34:49 kevin Exp
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

# 

set page_html  "[ad_admin_header "Confirm Deletion"]

<h2>Confirm Deletion</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index" "Categories &amp; Subcategories"] [list "category?[export_url_vars category_id category_name]" $category_name] [list "subcategory?[export_url_vars subcategory_id subcategory_name category_id category_name]" $subcategory_name] [list "subsubcategory?[export_url_vars subsubcategory_id subsubcategory_name subcategory_id subcategory_name category_id category_name]" $subsubcategory_name] "Delete this Subsubcategory"]

<hr>

<form method=post action=subsubcategory-delete-2>
[export_form_vars subsubcategory_id subcategory_id subcategory_name category_id category_name]
Please confirm that you wish to delete the subsubcategory $subsubcategory_name.  This will not delete the products in this subsubcategory (if any).  However, it will cause them to no longer be associated with this subsubcategory.
<p>
<center>
<input type=submit value=\"Confirm\">
</center>
</form>

[ad_admin_footer]
"
doc_return 200 text/html $page_html
