#  www/ecommerce/mailing-list-remove.tcl
ad_page_contract {
    @param category_id
    @param subcategory_id:optional
    @param subsubcategory_id:optional
    @param usca_p:optional
  

    @author
    @creation-date
    @cvs-id mailing-list-remove.tcl,v 3.4.2.5 2000/08/18 21:46:34 stevenp Exp
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    category_id:integer
    subcategory_id:optional
    subsubcategory_id:optional
    usca_p:optional

}



set user_id [ad_verify_and_get_user_id]

if {$user_id == 0} {
    
    set return_url "[ad_conn url]?[export_form_vars category_id subcategory_id subsubcategory_id]"

    ad_returnredirect "/register?[export_url_vars return_url]"
    return
}

# user session tracking
set user_session_id [ec_get_user_session_id]


ec_create_new_session_if_necessary [export_entire_form_as_url_vars]
# type2

set delete_string "delete from ec_cat_mailing_lists where user_id=:user_id"

if { [info exists category_id] && ![empty_string_p $category_id] } {
    append delete_string " and category_id=:category_id"
    set mailing_list_name [db_string get_mailing_list_name "select category_name from ec_categories where category_id=:category_id"]

} else {
    append delete_string " and category_id is null"
}

if { [info exists subcategory_id] && ![empty_string_p $subcategory_id] } {
    validate_integer "subcategory_id" $subcategory_id
    append delete_string " and subcategory_id=:subcategory_id"
    set mailing_list_name "[db_string get_mailing_list_name "select category_name from ec_categories where category_id=:category_id"]: [db_string get_subcat_ml_name "select subcategory_name from ec_subcategories where subcategory_id=:subcategory_id"]"

} else {
    append delete_string " and subcategory_id is null"
}
 

if { [info exists subsubcategory_id] && ![empty_string_p $subsubcategory_id] } {
    validate_integer "subsubcategory_id" $subsubcategory_id

    append delete_string " and subsubcategory_id=:subsubcategory_id"
    set mailing_list_name "[db_string get_cat_ml_name "select category_name from ec_categories where category_id=:category_id"]: [db_string get_ml_subcat_name "select subcategory_name from ec_subcategories where subcategory_id=:subcategory_id"]: [db_string get_subsub_ml_name "select subsubcategory_name from ec_subsubcategories where subsubcategory_id=:subsubcategory_id"]"

} else {
    append delete_string " and subsubcategory_id is null"
}

if { ![info exists mailing_list_name] } {
    ad_return_complaint 1 "You haven't specified which mailing list you want to be removed from."
    return
}

db_dml remove_user_from_mailing_list $delete_string

set re_add_link "<a href=\"mailing-list-add?[export_url_vars category_id subcategory_id subsubcategory_id]\">[ec_insecure_location][ec_url]mailing-list-add?[export_url_vars category_id subcategory_id subsubcategory_id]</a>"

set back_to_account_link "<a href=\"[ec_insecure_location][ec_url]account\">Your Account</a>"

set continue_shopping_options [ec_continue_shopping_options]
db_release_unused_handles

ec_return_template