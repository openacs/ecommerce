ad_page_contract {
    @param usca_p User session begun or not

    @author
    @creation-date
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @revision-date April 2002

} {
    usca_p:optional
}

if { ![ad_parameter -package_id [ec_id] UserClassAllowSelfPlacement ecommerce] } {
    ad_returnredirect index
    ad_script_abort
}

set user_id [ad_verify_and_get_user_id]
if {$user_id == 0} {
    set return_url "[ad_conn url]"
    ad_returnredirect "/register?[export_url_vars return_url]"
    ad_script_abort
}

set user_session_id [ec_get_user_session_id]
ec_create_new_session_if_necessary
ec_log_user_as_user_id_for_this_session

# Two variables for the ADP page

set user_classes_need_approval [ad_parameter -package_id [ec_id] UserClassApproveP ecommerce]
set user_class_select_list [ec_user_class_select_widget [db_list get_user_class_list_for_uid "
    select user_class_id 
    from ec_user_class_user_map 
    where user_id = :user_id"]]
set context_bar [template::adp_parse [acs_root_dir]/packages/[ad_conn package_key]/www/contextbar [list context_addition [list "Your Account"]]]
set ec_system_owner [ec_system_owner]

db_release_unused_handles

ad_return_template
