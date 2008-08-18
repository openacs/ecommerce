# interaction-add-2.tcl
ad_page_contract { 
    @param open_date:optional
    @param interaction_type:optional
    @param interaction_type_other:optional
    @param interaction_originator:optional 
    @param first_names:optional
    @param last_name:optional
    @param email:optional
    @param postal_code:optional
    @param other_id_info:optional 
    @param c_user_identification_id:optional
    @param issue_id:optional
    @param open_date

    @author
    @creation-date
    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    open_date:array,date,optional
    interaction_type:optional
    interaction_type_other:optional
    interaction_originator:optional 
    first_names:optional
    last_name:optional
    email:optional
    postal_code:optional
    other_id_info:optional 
    c_user_identification_id:optional
    issue_id:optional
    insert_id:integer
}

ad_require_permission [ad_conn package_id] admin

# If this is coming from interaction-add-3.tcl (meaning that they are adding
# another action to this interaction):
# interaction_id, c_user_identification_id ("c" stands for "confirmed" meaning
# that they've been through interaction-add-3.tcl and now they cannot change
# the user_identification_id)

# Possibly:
# return_to_issue

# the customer service rep must be logged on

set customer_service_rep [ad_get_user_id]
if {[empty_string_p $insert_id]} {
    set insert_id 1
}
if {$insert_id ==0 } { 

    # YYYY-MM-DD HH24:MI:SS
    set open_date_year  $open_date(year)
    set open_date_month $open_date(month)
    set open_date_day  $open_date(day)
    set open_date_time $open_date(time)

    set open_date_str "$open_date_year-$open_date_month-$open_date_day $open_date_time"
} 

if {$insert_id ==1} {
    set open_date_str [db_string select_time "select to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS') from dual"]

}


#doc_return  200 text/html "<b>year: $open_date_year <br>
#month: $open_date_month <br>
#day: $open_date_day<br>
#time: $open_date_time<br></b>"

if {$customer_service_rep == 0} {
    set return_url "[ad_conn url]?[export_entire_form_as_url_vars]"
    ad_returnredirect "/register.tcl?[export_url_vars return_url]"
    ad_script_abort
}

if { ![info exists interaction_id] } {

    set exception_count 0
    set exception_text ""
    
    if { ![info exists interaction_type] || [empty_string_p $interaction_type] } {
	incr exception_count
	append exception_text "<li>You forgot to specify the method of inquiry (phone/email/etc.).\n"
    } elseif { $interaction_type == "other" && (![info exists interaction_type_other] || [empty_string_p $interaction_type_other]) } {
	incr exception_count
	append exception_text "<li>You forgot to fill in the text box detail for Other.\n"
    } elseif { $interaction_type != "other" && ([info exists interaction_type_other] && ![empty_string_p $interaction_type_other]) } {
	incr exception_count
	append exception_text "<li>You selected \"Inquired via: [string toupper [string index $interaction_type 0]][string range $interaction_type 1 [expr [string length $interaction_type] -1]]\", but you also filled in something in the \"If Other, specify\" field.  This is inconsistent.\n"
    }
    
    if { $exception_count > 0 } {
	ad_return_complaint $exception_count $exception_text
        ad_script_abort
    }

    # done error checking
}


# Have to generate action_id
# action_id will be used by the next page to tell whether the user pushed
# submit twice
# interaction_id will not be generated until the next page (if it doesn't
# exist) so that I can use the fact of its existence or lack of existence
# to create this page's UI

set action_id [db_nextval ec_action_id_sequence]



append doc_body "[ad_admin_header "One Issue"] 
<h2>One Issue</h2>
[ad_context_bar [list "../index.tcl" "Ecommerce([ec_system_name])"] [list "index.tcl" "Customer Service Administration"] "One Issue (part of New Interaction)"]

<hr noshade>"

if { ![info exists c_user_identification_id] } {
    append doc_body "
    <p><b>Customer identification:</b></p>
    <p>
    Here's what we could determine about the customer given the information you typed
    into the previous form:
    </p><ul>
    "
    
    set positively_identified_p 0
    
    # see if we can find their city/state from the zip code
    
    set location [ec_location_based_on_zip_code $postal_code]

    if { ![empty_string_p $location] } {
	append doc_body "<li>They live in $location.</li>"
    }

    
    # I'll be setting variables d_user_id, d_user_identification_id, d_first_names, etc.,
    # based on the user info they typed into the last form.  "d" stands for "determined",
    # meaning that I determined it, as opposed to it being something that they typed in
    
    # if their email address was filled in, see if they're a registered user
    if { ![empty_string_p $email] } {
	set email [string toupper $email]
	if {  [db_0or1row get_does_row_exist_p "select first_names as d_first_names, last_name as d_last_name, user_id as d_user_id from cc_users where email =lower(:email) "]==1 } {
	

	    append doc_body "<li>This is a registered user of the system: <a target=user_window href=\"[ec_acs_admin_url]users/one?user_id=$d_user_id\">$d_first_names $d_last_name</a>.
	    [export_form_vars d_user_id]"
	    set positively_identified_p 1
	}
	
    }
    
    if { !$positively_identified_p } {
	# then keep trying to identify them
	
	if { ![empty_string_p $first_names] || ![empty_string_p $last_name] } {
	    if { ![empty_string_p $first_names] && ![empty_string_p $last_name] } {
		set sql "select email, user_id as d_user_id from cc_users where upper(first_names)=upper (:first_names) and upper(last_name)=upper(:last_name)"
		db_foreach get_user_ids $sql {
		    append doc_body "<li>This may be the registered user <a target=user_window href=\"customer-history?customer_type=user_id&customer_id=$d_user_id\">$first_names $last_name</a> $email (check here <input type=checkbox name=d_user_id value=$d_user_id> if this is correct).</li>"
		}
	    } elseif { ![empty_string_p $first_names] } {
		set sql "select email, user_id as d_user_id, last_name as d_last_name from cc_users where upper(first_names)=upper(:first_names)"
		
		db_foreach get_user_id_and_lname $sql {
		    
		    append doc_body "<li>This may be the registered user <a target=user_window href=\"customer-history?customer_type=user_id&customer_id=$d_user_id\">$first_names $d_last_name</a> $email (check here <input type=checkbox name=d_user_id value=$d_user_id> if this is correct).\n</li>"
		}
		
	    } elseif { ![empty_string_p $last_name] } {
		set sql "select email, user_id as d_user_id, first_names as d_first_names from cc_users where upper(last_name)=upper(:last_name)"
		
		db_foreach get_user_id_and_names $sql {
		    
		    append doc_body "<li>This may be the registered user <a target=user_window href=\"customer-history?customer_type=user_id&customer_id=$d_user_id\">$d_first_names $last_name</a> $email (check here <input type=checkbox name=d_user_id value=$d_user_id> if this is correct).\n</li>"
		}
		
	    }
	}

	# also see if they might be a non-user who
	# has had an interaction before
	
	set already_selected_user_identification_id_list [list]
	if { ![empty_string_p $email] } {
	    set sql "select user_identification_id as d_user_identification_id from ec_user_identification where email=lower(:email) and user_id is null"
	    
	    db_foreach get_user_identification $sql {
		
		append doc_body "<li>This may be the non-registered person who has had a previous interaction with us: [ec_user_identification_summary $d_user_identification_id "t"] (check here <input type=checkbox name=d_user_identification_id value=$d_user_identification_id> if this is correct).</li>"
		lappend already_selected_user_identification_id_list $d_user_identification_id
	    }
	}
	
	set additional_and_clause ""
	if { [llength $already_selected_user_identification_id_list] > 0 } {
	    set additional_and_clause "and user_identification_id not in ([join $already_selected_user_identification_id_list ", "])"
	}
	
	if { ![empty_string_p $first_names] || ![empty_string_p $last_name] } {
	    if { ![empty_string_p $first_names] && ![empty_string_p $last_name] } {
		set sql "select user_identification_id as d_user_identification_id from ec_user_identification where upper(first_names)=upper(:first_names) and upper(last_name)=upper(:last_name) and user_id is null $additional_and_clause"
	    } elseif { ![empty_string_p $first_names] } {
		set sql "select user_identification_id as d_user_identification_id from ec_user_identification where upper(first_names)=upper(:first_names) and user_id is null $additional_and_clause"
	    } elseif { ![empty_string_p $last_name] } {
		set sql "select user_identification_id as d_user_identification_id from ec_user_identification where upper(last_name)=upper(:last_name) and user_id is null $additional_and_clause"
	    }
	    
	    db_foreach get_user_identification_info $sql {
# need to add a db0or1row select ec_customer_service_issues.user_identification where ec_customer_service_issues.issue_id = ec_cs_issue_type_map.issue_id and ec_customer_service_issues.user_identification = $user_identification  *** actually, see if you can add the restriction to the loops query, and check if db_foreach skips if no hits, otherwise have to check for it first.
# if exists then proceed with this iteration of the loop, otherwise ignore it as a false positive.		
# the other possibility is to identify when the customer_service.issue_id is created, and why the map is not...
		append doc_body "<li>This may be the non-registered person who has had a previous interaction with us: [ec_user_identification_summary $d_user_identification_id "t"] (check here <input type=checkbox name=d_user_identification_id value=$d_user_identification_id> if this is correct).</li>"
		lappend already_selected_user_identification_id_list $d_user_identification_id
	    }
	}
	
	if { [llength $already_selected_user_identification_id_list] > 0 } {
	    set additional_and_clause "and user_identification_id not in ([join $already_selected_user_identification_id_list ", "])"
	}
	
	if { ![empty_string_p $other_id_info] } {
	    set sql "select user_identification_id as d_user_identification_id from ec_user_identification where other_id_info like '%[DoubleApos $other_id_info]%' $additional_and_clause"
	    
	    db_foreach get_user_identification_info $sql {
		
		append doc_body "<li>This may be the non-registered person who has had a previous interaction with us: [ec_user_identification_summary $d_user_identification_id "t"] (check here <input type=checkbox name=d_user_identification_id value=$d_user_identification_id> if this is correct).</li>"
		lappend already_selected_user_identification_id_list $d_user_identification_id
	    }
	    
	}
	
	if { [llength $already_selected_user_identification_id_list] > 0 } {
	    set additional_and_clause "and user_identification_id not in ([join $already_selected_user_identification_id_list ", "])"
	}
	
	if { ![empty_string_p $postal_code] } {
	    set sql "select user_identification_id as d_user_identification_id from ec_user_identification where postal_code=:postal_code $additional_and_clause"
	    
	    db_foreach get_user_ids_by_postal_code $sql {
		
		append doc_body "<li>This may be the non-registered person who has had a previous interaction with us: [ec_user_identification_summary $d_user_identification_id "t"] (check here <input type=checkbox name=d_user_identification_id value=$d_user_identification_id> if this is correct).</li>"
		lappend already_selected_user_identification_id_list $d_user_identification_id
	    }
	}
    }
    append doc_body "</ul>"
}

append doc_body "<h3>One issue</h3><p>A customer may discuss several issues during the course of one interaction.  Please
enter the information about only one issue below:</p>

<form method=\"post\" action=\"interaction-add-3\">
[export_form_vars interaction_id c_user_identification_id action_id open_date_str interaction_type interaction_type_other interaction_originator first_names last_name email postal_code other_id_info return_to_issue insert_id]

<table cellspacing=\"1\" cellpadding=\"2\">"

if { [info exists c_user_identification_id] } {
    append doc_body "<tr>
    <td bgcolor=\"\#cccccc\" valign=\"top\" align=\"right\">Customer:</td>
    <td bgcolor=\"\#cccccc\" valign=\"top\">[ec_user_identification_summary $c_user_identification_id "t"]"

    if { [info exists postal_code] } {
	append doc_body "<br>
	[ec_location_based_on_zip_code $postal_code]"
    }

    append doc_body "</td>
    </tr>"
}

if { ![info exists issue_id] } {
    append doc_body "<tr>
    <td bgcolor=\"\#cccccc\" valign=\"top\" align=\"right\">Previous Issue ID:</td>
    <td bgcolor=\"\#cccccc\" valign=\"top\"><input type=\"text\" size=\"4\" name=\"issue_id\">
    If this is a new issue, please leave this blank (a new Issue ID will be generated)</td>
    </tr>
    <tr>
    <td bgcolor=\"\#cccccc\" valign=\"top\" align=\"right\">New Issue Type:</td>
    <td bgcolor=\"\#cccccc\" valign=\"top\"> (leave blank if based on an existing issue) [ec_issue_type_widget]</td>
    </tr>
    <tr>
    <td bgcolor=\"\#99ccff\" valign=\"top\" align=\"right\">Order ID:</td>
    <td bgcolor=\"\#99ccff\" valign=\"top\"><input type=\"text\" size=\"7\" name=\"order_id\">
    Fill this in if this inquiry is about a specific order.
    </td>
    </tr>
    "
} else {
    set order_id [db_string get_order_id "select order_id from ec_customer_service_issues where issue_id=:issue_id"]
    set issue_type_list [db_list get_is`<sue_type_list "select issue_type from ec_cs_issue_type_map where issue_id=:issue_id"]

    append doc_body "<tr>
    <td bgcolor=\"\#99ccff\" valign=\"top\" align=\"right\">Issue ID:</td>
    <td bgcolor=\"\#99ccff\" valign=\"top\">$issue_id[export_form_vars issue_id]</td>
    </tr>
    <tr>
    <td bgcolor=\"\#99ccff\" valign=\"top\" align=\"right\">Issue Type</td>
    <td bgcolor=\"\#99ccff\" valign=\"top\">[join $issue_type_list ", "]</td>
    </tr>
    <tr>
    <td bgcolor=\"\#99ccff\" valign=\"top\" align=\"right\">Order ID:</td>
    <td bgcolor=\"\#99ccff\" valign=\"top\">[ec_decode $order_id "" "none" $order_id]</td>
    </tr>
"
}
append doc_body "<tr>
<td bgcolor=\"\#99ccff\" valign=\"top\" align=\"right\">Issue details:<br>(action_details)</td>
<td bgcolor=\"\#99ccff\" valign=\"top\"><textarea wrap name=\"action_details\" rows=\"6\" cols=\"45\"></textarea></td>
</tr>
<tr>
<td bgcolor=\"\#99ccff\" valign=\"top\" align=\"right\">Resources used:</td>
<td bgcolor=\"\#99ccff\" valign=\"top\">Information used to respond to inquiry [ec_info_used_widget]</td>
</tr>
<tr>
<td bgcolor=\"\#99ccff\" valign=\"top\" align=\"right\" rowspan=\"2\">Requires follow-up?</td>
<td bgcolor=\"\#99ccff\" valign=\"top\">
<input type=radio name=close_issue_p value=\"f\" checked>yes <b>requires follow-up</b><br>
&nbsp;&nbsp;&nbsp;&nbsp;Please elaborate:<textarea wrap name=\"follow_up_required\" rows=\"2\" cols=\"45\"></textarea>

</td>
</tr>
<tr>

<td bgcolor=\"\#99ccff\" valign=\"top\"><input type=\"radio\" name=\"close_issue_p\" value=\"t\">no (resolved)</td>
</tr>
</table>
"


append doc_body "<center>Customer 
<input type=\"submit\" name=\"submit\" value=\"Interaction complete\">
<input type=\"submit\" name=\"submit\" value=\"Add another issue as part of this interaction\">
</center>
</form>
[ad_admin_footer]
"
doc_return  200 text/html $doc_body

