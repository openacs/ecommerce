#  www/[ec_url_concat [ec_url] /admin]/user-classes/index.tcl
ad_page_contract {

  @author
  @creation-date
  @cvs-id
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
}

ad_require_permission [ad_conn package_id] admin

set page_html "[ad_admin_header "User Class Administration"]

<h2>User Class Administration</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] "User Classes"]

<hr>

<h3>Current User Classes</h3>

<ul>
"

db_foreach get_uc_info_lines "
   select ec_user_classes.user_class_id, 
          ec_user_classes.user_class_name,
          count(user_id) as n_users
     from ec_user_classes, ec_user_class_user_map m
    where ec_user_classes.user_class_id = m.user_class_id(+)
 group by ec_user_classes.user_class_id, ec_user_classes.user_class_name
 order by user_class_name
" {

    append page_html "<li><a href=\"one?[export_url_vars user_class_id user_class_name]\">$user_class_name</a> <font size=-1>($n_users user[ec_decode $n_users "1" "" "s"]"

    if { [util_memoize {ad_parameter -package_id [ec_id] UserClassApproveP ecommerce} [ec_cache_refresh]] } {
	set n_approved_users [db_string get_n_approved_users "
        select count(*) as approved_n_users
          from ec_user_class_user_map
         where user_class_approved_p = 't'
          and user_class_id=:user_class_id
        "]

	append page_html " , $n_approved_users approved user[ec_decode $n_approved_users "1" "" "s"]"
    }
    append page_html ")</font>\n"
} if_no_rows {

    append page_html "You haven't set up any user classes.\n"
}

# For audit tables
set table_names_and_id_column [list ec_user_classes ec_user_classes_audit user_class_id]

append page_html "
</ul>

<p>

<h3>Actions</h3>

<ul>
<li><a href=\"[ec_url_concat [ec_url] /admin]/audit-tables?[export_url_vars table_names_and_id_column]\">Audit All User Classes</a>
</ul>

<p>

<h3>Add a New User Class</h3>

<ul>

<form method=post action=add>
Name: <input type=text name=user_class_name size=30>
<input type=submit value=\"Add\">
</form>

</ul>

[ad_admin_footer]
"

doc_return  200 text/html $page_html