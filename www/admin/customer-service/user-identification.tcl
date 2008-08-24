# user-identification.tcl
ad_page_contract {
    @param user_identification_id
    @author
    @creation-date
    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    user_identification_id
}
 
ad_require_permission [ad_conn package_id] admin

db_1row get_user_id_info "select * from ec_user_identification where user_identification_id=:user_identification_id"

if { ![empty_string_p $user_id] } {
    ad_returnredirect "[ec_acs_admin_url]users/one.tcl?user_id=$user_id"
    ad_script_abort
}

set title "Unregistered User"
set context [list [list index "Customer Service"] $title]

set location [ec_location_based_on_zip_code $postal_code]

set record_created_html "[util_AnsiDatetoPrettyDate $date_added]"
set all_cs_issues_by_one_user_html "[ec_all_cs_issues_by_one_user "" $user_identification_id]"

set export_form_vars_html [export_form_vars user_identification_id]

set positively_identified_p 0

# if their email address was filled in, see if they're a registered user
set comments_about_user_html ""
if { ![empty_string_p $email] } {
    set email [string toupper $email]
    set row_exists_p [db_0or1row get_row_exists_name "select first_names as d_first_names, last_name as d_last_name, user_id as d_user_id from cc_users where email = lower(:email)"]
    if { [info exists d_user_id] } {
        append comments_about_user_html "<li>This is a registered user of the system: <a target=user_window href=\"[ec_acs_admin_url]users/one?user_id=$d_user_id\">$d_first_names $d_last_name</a></li>."
        append export_form_vars_html [export_form_vars d_user_id]
        set positively_identified_p 1
    }
}
if { !$positively_identified_p } {
    # then keep trying to identify them
    if { ![empty_string_p $first_names] || ![empty_string_p $last_name] } {
        if { ![empty_string_p $first_names] && ![empty_string_p $last_name] } {
            set sql "select user_id as d_user_id from cc_users where upper(first_names)=upper(:first_names) and upper(last_name)=upper(:last_name)"
            db_foreach get_user_ids_like_person $sql {
                append comments_about_user_html "<li>This may be the registered user <a target=\"_blank\" href=\"[ec_acs_admin_url]users/one?user_id=$d_user_id\">$first_names $last_name</a>(opens in new window) Check here <input type=checkbox name=d_user_id value=$d_user_id> if this is correct.</li>\n"
            }
        } elseif { ![empty_string_p $first_names] } {
            set sql "select user_id as d_user_id, last_name as d_last_name from cc_users where upper(first_names)=upper(:first_names)"
            db_foreach get_d_user_ids_by_first_name $sql {
                append comments_about_user_html "<li>This may be the registered user <a target=\"_blank\" href=\"[ec_acs_admin_url]users/one?user_id=$d_user_id\">[ad_quotehtml $first_names]</a>(opens in new window) Check here <input type=checkbox name=d_user_id value=$d_user_id> if this is correct.</li>\n"
            }
        } elseif { ![empty_string_p $last_name] } {
            set sql "select user_id as d_user_id, first_names as d_first_names from cc_users where upper(last_name)=upper(:last_name)"
            db_foreach get_maybe_last_name $sql {
                append comments_about_user_html "<li>This may be the registered user <a target=\"_blank\" href=\"[ec_acs_admin_url]users/one?user_id=$d_user_id\">[ad_quotehtml $last_name]</a> (opens in new window) Check here <input type=checkbox name=d_user_id value=$d_user_id> if this is correct.</li>\n"
            }
        }
    }
    # see if they have a gift certificate that a registered user has claimed.
    # email_template_id 5 is the automatic email sent to gift certificate recipients.
    set sql "select g.user_id as d_user_id, u.first_names as d_first_names, u.last_name as d_last_name
     from ec_automatic_email_log l, ec_gift_certificates g, cc_users u
     where g.user_id=u.user_id
     and l.gift_certificate_id=g.gift_certificate_id
     and l.user_identification_id=$user_identification_id
     and l.email_template_id=5
     group by g.user_id, u.first_names, u.last_name"
    db_foreach get_user_id_by_gcs $sql {
        append comments_about_user_html "<li>This may be the registered user <a target=\"_blank\" href=\"[ec_acs_admin_url]users/one?user_id=$d_user_id\">[ad_quotehtml "$d_first_names $d_last_name"]</a> who claimed a gift certificate sent to [ad_quotehtml $email] (check here <input type=checkbox name=d_user_id value=$d_user_id> if this is correct).\n"
    }
}
