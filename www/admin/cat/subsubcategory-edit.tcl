# /www/[ec_url_concat [ec_url] /admin]/cat/subsubcategory-edit.tcl
ad_page_contract {

    Modifies name of ecommerce product subsubcategory.

    @param category_id the ID of the category
    @param category_name the name of the category
    @param subcategory_id the ID of this subcategory
    @param subcategory_name the name of this subcategory
    @param subsubcategory_id the ID of this subcategory
    @param subsubcategory_name the new name of this subcategory

    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    category_name:trim,notnull
    category_id:integer,notnull
    subcategory_name:trim,notnull
    subcategory_id:integer,notnull
    subsubcategory_id:integer,notnull
    subsubcategory_name:trim,notnull
}

ad_require_permission [ad_conn package_id] admin

# we need them to be logged in
set user_id [ad_verify_and_get_user_id]

if {$user_id == 0} {
    
    set return_url "[ad_conn url]?[export_url_vars category_name category_id subcategory_id subcategory_name]"

    ad_returnredirect "/register?[export_url_vars return_url]"
    return
}


set address [ns_conn peeraddr]
db_dml update_subsubcategory "update ec_subsubcategories
set subsubcategory_name=:subsubcategory_name,
last_modified=sysdate,
last_modifying_user=:user_id,
modified_ip_address=:address
where subsubcategory_id=:subsubcategory_id"
db_release_unused_handles

ad_returnredirect "subsubcategory?[export_url_vars category_id category_name subcategory_id subcategory_name subsubcategory_id subsubcategory_name]"
