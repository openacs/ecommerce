ad_page_contract {

    Add the visitor to the selected mailing list. Mailling list are
    organized by (sub)(sub)categories.

    @param category_id:integer
    @param subcategory_id:optional
    @param subsubcategory_id:optional
    @param usca_p:optional

    @author
    @creation-date
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @revision-date April 2002

} {
    category_id:integer,notnull
    subcategory_id:integer,optional
    subsubcategory_id:integer,optional
    usca_p:optional
}

set user_id [ad_conn user_id]
if {$user_id == 0} {
    set return_url "[ad_conn url]?[export_form_vars category_id subcategory_id subsubcategory_id]"
    ad_returnredirect "/register?[export_url_vars return_url]"
    ad_script_abort
}

# user session tracking
set user_session_id [ec_get_user_session_id]

ec_create_new_session_if_necessary [export_entire_form_as_url_vars]

if { ![info exists subcategory_id] || [empty_string_p $subcategory_id] } {
    set check_string "select count(*) from ec_cat_mailing_lists where user_id=:user_id and category_id=:category_id and subcategory_id is null"
    set insert_string "insert into ec_cat_mailing_lists (user_id, category_id) values (:user_id, :category_id)"
    set mailing_list_name [db_string get_list_name "select category_name from ec_categories where category_id=:category_id"]
} elseif { ![info exists subsubcategory_id] || [empty_string_p $subsubcategory_id] } {
    set check_string "select count(*) from ec_cat_mailing_lists where user_id=:user_id and subcategory_id=:subcategory_id and subsubcategory_id is null"
    set insert_string "insert into ec_cat_mailing_lists (user_id, category_id, subcategory_id) values (:user_id, :category_id, :subcategory_id)"
    set mailing_list_name "[db_string get_mailing_list_name "select category_name from ec_categories where category_id=:category_id"]: [db_string get_subcat_listname "select subcategory_name from ec_subcategories where subcategory_id=:subcategory_id"]"
} elseif { [info exists subsubcategory_id] && ![empty_string_p $subsubcategory_id] } {
    validate_integer "subcategory_id" $subcategory_id
    validate_integer "subsubcategory_id" $subsubcategory_id
    set check_string "select count(*) from ec_cat_mailing_lists where user_id=:user_id and subsubcategory_id=:subsubcategory_id"
    set insert_string "insert into ec_cat_mailing_lists (user_id, category_id, subcategory_id, subsubcategory_id) values (:user_id, :category_id, :subcategory_id, :subsubcategory_id)"
    set mailing_list_name "[db_string get_category_name "select category_name from ec_categories where category_id=:category_id"]: [db_string get_subcategory_name "select subcategory_name from ec_subcategories where subcategory_id=:subcategory_id"]: [db_string get_subsubcategory_name "select subsubcategory_name from ec_subsubcategories where subsubcategory_id=:subsubcategory_id"]"
} else {
    set check_string "select count(*) from ec_cat_mailing_lists where user_id=:user_id and category_id is null"
    set insert_string "insert into ec_cat_mailing_lists (user_id) values (:user_id)"
}

if { [db_string get_check_string $check_string] == 0 } {
    db_dml add_to_mailing_list $insert_string
}

set remove_link "<a href=\"mailing-list-remove?[export_url_vars category_id subcategory_id subsubcategory_id]\">unsubscribe from $mailing_list_name</a>"

set title "You subscribed to the $mailing_list_name mailing list"
set context_bar [template::adp_parse [acs_root_dir]/packages/[ad_conn package_key]/www/contextbar [list context_addition [list $title]]]
set ec_system_owner [ec_system_owner]
db_release_unused_handles

ad_return_template
