#  www/ecommerce/update-user-classes.tcl
ad_page_contract {
    @param usca_p User session begun or not
    @author
    @creation-date
    @cvs-id update-user-classes.tcl,v 3.1.6.7 2000/08/18 21:46:37 stevenp Exp
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    usca_p:optional
}


set user_id [ad_verify_and_get_user_id]

if {$user_id == 0} {
    
    set return_url "[ad_conn url]"

    ad_returnredirect "/register?[export_url_vars return_url]"
    return
}

set user_session_id [ec_get_user_session_id]


ec_create_new_session_if_necessary
# type1

ec_log_user_as_user_id_for_this_session

# two variables for the ADP page
set user_classes_need_approval [ad_parameter -package_id [ec_id] UserClassApproveP ecommerce]

set user_class_select_list [ec_user_class_select_widget [db_list get_user_class_list_for_uid "select user_class_id 
from ec_user_class_user_map 
where user_id = :user_id"]]
db_release_unused_handles

ec_return_template
