# user-identification.tcl

ad_page_contract {
    @param user_identification_id
    @author
    @creation-date
    @cvs-id user-identification.tcl,v 3.3.2.5 2000/09/22 01:34:54 kevin Exp
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    user_identification_id
}
# 
ad_require_permission [ad_conn package_id] admin

db_1row get_user_id_info "select * from ec_user_identification where user_identification_id=:user_identification_id"


if { ![empty_string_p $user_id] } {
    ad_returnredirect "[ec_acs_admin_url]users/one.tcl?user_id=$user_id"
    return
}



set page_title "Unregistered User"
append doc_body "[ad_admin_header $page_title]
<h2>$page_title</h2>

[ad_admin_context_bar [list "../index.tcl" "Ecommerce([ec_system_name])"] [list "index.tcl" "Customer Service Administration"] $page_title]

<hr>

<h3>What we know about this user</h3>

<table>
<tr>
<td align=right><b>First Name</td>
<td>$first_names</td>
</tr>
<tr>
<td align=right><b>Last Name</td>
<td>$last_name</td>
</tr>
<tr>
<td align=right><b>Email</td>
<td>$email</td>
</tr>
<tr>
<td align=right><b>Zip Code</td>
<td>$postal_code
"

set location [ec_location_based_on_zip_code $postal_code]
if { ![empty_string_p $location] } {
    append doc_body " ($location)"
}

append doc_body "</td>
</tr>
<tr>
<td align=right><b>Other Identifying Info</td>
<td>$other_id_info</td>
</tr>
<tr>
<td align=right><b>Record Created</b></td>
<td>[util_AnsiDatetoPrettyDate $date_added]</td>
</tr>
</table>

<h3>Customer Service Issues</h3>

[ec_all_cs_issues_by_one_user "" $user_identification_id]

<h3>Edit User Info</h3>

<form method=post action=user-identification-edit>
[export_form_vars user_identification_id]
<table>
<tr>
<td>First Name:</td>
<td><input type=text name=first_names size=15 value=\"[ad_quotehtml $first_names]\"> Last Name: <input type=text name=last_name size=20 value=\"[ad_quotehtml $last_name]\"></td>
</tr>
<tr>
<td>Email Address:</td>
<td><input type=text name=email size=30 value=\"[ad_quotehtml $email]\"></td>
</tr>
<tr>
<td>Zip Code:</td>
<td><input type=text name=postal_code size=5 maxlength=5 value=\"[ad_quotehtml $postal_code]\"></td>
</tr>
<tr>
<td>Other Identifying Info:</td>
<td><input type=text name=other_id_info size=30 value=\"[ad_quotehtml $other_id_info]\"></td>
</tr>
</table>

<center>
<input type=submit value=\"Update\">
</center>
</form>

<h3>Try to match this user up with a registered user</h3>
<ul>
<form method=post action=user-identification-match>
[export_form_vars user_identification_id]
"

set positively_identified_p 0

# if their email address was filled in, see if they're a registered user
if { ![empty_string_p $email] } {
    set email [string toupper $email]
    set row_exists_p [db_0or1row get_row_exists_name "select first_names as d_first_names, last_name as d_last_name, user_id as d_user_id from cc_users where email = lower(:email)"]
    
    if { [info exists d_user_id] } {
	append doc_body "<li>This is a registered user of the system: <a target=user_window href=\"[ec_acs_admin_url]users/one?user_id=$d_user_id\">$d_first_names $d_last_name</a>.
	[export_form_vars d_user_id]"
	set positively_identified_p 1
    }
    
}

if { !$positively_identified_p } {
    # then keep trying to identify them
    
    if { ![empty_string_p $first_names] || ![empty_string_p $last_name] } {
	if { ![empty_string_p $first_names] && ![empty_string_p $last_name] } {
	    set sql "select user_id as d_user_id from cc_users where upper(first_names)=upper(:first_names) and upper(last_name)=upper(:last_name)"
	    db_foreach get_user_ids_like_person $sql {
		
		append doc_body "<li>This may be the registered user <a target=user_window href=\"[ec_acs_admin_url]users/one?user_id=$d_user_id\">$first_names $last_name</a> (check here <input type=checkbox name=d_user_id value=$d_user_id> if this is correct).\n"
	    }
	} elseif { ![empty_string_p $first_names] } {
	    set sql "select user_id as d_user_id, last_name as d_last_name from cc_users where upper(first_names)=upper(:first_names)"
	    
	    db_foreach get_d_user_ids_by_first_name $sql {
		
		append doc_body "<li>This may be the registered user <a target=user_window href=\"[ec_acs_admin_url]users/one?user_id=$d_user_id\">$first_names $d_last_name</a> (check here <input type=checkbox name=d_user_id value=$d_user_id> if this is correct).\n"
	    }
	    
	} elseif { ![empty_string_p $last_name] } {
	    set sql "select user_id as d_user_id, first_names as d_first_names from cc_users where upper(last_name)=upper(:last_name)"
	    
	    db_foreach get_maybe_last_name $sql {
		
		append doc_body "<li>This may be the registered user <a target=user_window href=\"[ec_acs_admin_url]users/one?user_id=$d_user_id\">$d_first_names $last_name</a> (check here <input type=checkbox name=d_user_id value=$d_user_id> if this is correct).\n"
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
	
	append doc_body "<li>This may be the registered user <a target=user_window href=\"[ec_acs_admin_url]users/one?user_id=$d_user_id\">$d_first_names $d_last_name</a> who claimed a gift certificate sent to $email (check here <input type=checkbox name=d_user_id value=$d_user_id> if this is correct).\n"
    }
}

if { [info exists d_user_id] } {
    append doc_body "<p>
    <center>
    <input type=submit value=\"Confirm they are the same person\">
    </center>"
} else {
    append doc_body "No matches found."
}

append doc_body "</form>
</ul>
[ad_admin_footer]
"


doc_return  200 text/html $doc_body
