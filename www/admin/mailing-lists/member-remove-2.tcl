# member-remove-2.tcl

ad_page_contract { 
    @param category_id
    @param subcategory_id
    @param subsubcategory_id
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

if { ![empty_string_p $subsubcategory_id] } {
    db_dml delete_from_mailing_lists "delete from ec_cat_mailing_lists where user_id=:user_id and subsubcategory_id=:subsubcategory_id"
} elseif { ![empty_string_p $subcategory_id] } {
    db_dml delete_from_mailing_lists_2 "delete from ec_cat_mailing_lists where user_id=:user_id and subcategory_id=:subcategory_id and subsubcategory_id is null"
} elseif { ![empty_string_p $category_id] } {
    db_dml delete_from_mailing-lists_by_category "delete from ec_cat_mailing_lists where user_id=:user_id and category_id=:category_id and subcategory_id is null"
} else {
    db_dml delete_just_from_category "delete from ec_cat_mailing_lists where user_id=:user_id and category_id is null"
}
db_release_unused_handles

ad_returnredirect "one.tcl?[export_url_vars category_id subcategory_id subsubcategory_id]"


