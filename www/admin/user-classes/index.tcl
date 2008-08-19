#  www/[ec_url_concat [ec_url] /admin]/user-classes/index.tcl
ad_page_contract {

  @author
  @creation-date
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
}

ad_require_permission [ad_conn package_id] admin

set title "User Classes"
set context [list $title]

set user_class_approve_p [parameter::get -package_id [ec_id] -parameter UserClassApproveP -default 1]

set uc_info_lines_count 0
set uc_info_lines_html ""
db_foreach get_uc_info_lines "
   select ec_user_classes.user_class_id, 
          ec_user_classes.user_class_name,
          count(user_id) as n_users
     from ec_user_classes, ec_user_class_user_map m
    where ec_user_classes.user_class_id = m.user_class_id(+)
 group by ec_user_classes.user_class_id, ec_user_classes.user_class_name
 order by user_class_name" {

    append uc_info_lines_html "<li><a href=\"one?[export_url_vars user_class_id user_class_name]\">$user_class_name</a> ($n_users user[ec_decode $n_users "1" "" "s"]"
    incr uc_info_lines_count
    if { $user_class_approve_p } {
        set n_approved_users [db_string get_n_approved_users "
        select count(*) as approved_n_users
          from ec_user_class_user_map
         where user_class_approved_p = 't'
          and user_class_id=:user_class_id"]

        append uc_info_lines_html " , $n_approved_users approved user[ec_decode $n_approved_users "1" "" "s"]"
    }
    append uc_info_lines_html ")</li>\n"
} 

# For audit tables
set table_names_and_id_column [list ec_user_classes ec_user_classes_audit user_class_id]

set audit_url_html "[ec_url_concat [ec_url] /admin]/audit-tables?[export_url_vars table_names_and_id_column]"
