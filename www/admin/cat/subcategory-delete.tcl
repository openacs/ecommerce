#  www/[ec_url_concat [ec_url] /admin]/cat/subcategory-delete.tcl
ad_page_contract {

    Confirmation page for deleting an ecommerce product subcategory.

    @param category_id the ID of the category
    @param category_name the name of the category
    @param subcategory_id the ID of the subcategory
    @param subcategory_name the ID of the subcategory

    @cvs-id subcategory-delete.tcl,v 3.1.6.4 2000/09/22 01:34:48 kevin Exp
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    category_id:integer,notnull
    category_name:notnull
    subcategory_id:integer,notnull
    subcategory_name:notnull
}

ad_require_permission [ad_conn package_id] admin

set page_html "[ad_admin_header "Confirm Deletion"]

<h2>Confirm Deletion</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index" "Categories &amp; Subcategories"] [list "category?[export_url_vars category_id category_name]" $category_name] [list "subcategory?[export_url_vars subcategory_id subcategory_name category_id category_name]" $subcategory_name] "Delete this Subcategory"]

<hr>

<form method=post action=subcategory-delete-2>
[export_form_vars subcategory_id category_id category_name]
Please confirm that you wish to delete the category $category_name.  Please also note the following:
<p>
<ul>
<li>This will delete all subsubcategories of the subcategory $subcategory_name.
<li>This will not delete the products in this subcategory (if any).  However, it will cause them to no longer be associated with this subcategory.
</ul>
<p>
<center>
<input type=submit value=\"Confirm\">
</center>
</form>

[ad_admin_footer]
"
doc_return  200 text/html $page_html
