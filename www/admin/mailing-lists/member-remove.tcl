# member-remove.tcl

ad_page_contract {  
    @param category_id
    @param subcategory_id:optional
    @param subsubcategory_id:optional
    @param user_id

    @author
    @creation-date
    @cvs-id member-remove.tcl,v 3.1.6.3 2000/09/22 01:34:56 kevin Exp
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    category_id
    subcategory_id:optional
    subsubcategory_id:optional
    user_id
}

ad_require_permission [ad_conn package_id] admin

append doc_body "[ad_admin_header "Confirm Removal"]

<h2>Confirm Removal</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index.tcl" "Mailing Lists"] "Confirm Removal"]

<hr>

Please confirm that you wish to remove this user from this mailing list.

<form method=post action=member-remove-2>
[export_form_vars category_id subcategory_id subsubcategory_id user_id]
<center>
<input type=submit value=\"Confirm\">
</center>
</form>

[ad_admin_footer]
"



doc_return  200 text/html $doc_body


