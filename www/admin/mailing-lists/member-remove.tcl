# member-remove.tcl
ad_page_contract {  
    @param category_id
    @param subcategory_id:optional
    @param subsubcategory_id:optional
    @param user_id

    @author
    @creation-date
    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    category_id
    subcategory_id:optional
    subsubcategory_id:optional
    user_id
}

ad_require_permission [ad_conn package_id] admin

set title "Confirm Removal"
set context [list [list index "Mailing Lists"] $title]

set export_form_vars_html [export_form_vars category_id subcategory_id subsubcategory_id user_id]
