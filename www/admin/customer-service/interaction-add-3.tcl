# interaction-add-3.tcl

ad_page_contract {  
    @param open_date_str:optional
    @param interaction_type:optional
    @param interaction_type_other:optional
    @param interaction_originator:optional
    @param first_names:optional
    @param last_name:optional
    @param email:optional
    @param postal_code:optional
    @param other_id_info:optional
    @param  d_user_id:optional
    @param  d_user_identification_id:optional
    @param interaction_id:optional 
    @param c_user_identification_id:optional
    @param postal_code:optional
    @param order_id:naturalnum,optional
    @param issue_type:optional,multiple
    @param issue_id:naturalnum,optional
    @param action_details:notnull
    @param action_id:notnull,naturalnum
    @param close_issue_p
    @param {issue_type_list "" }
    @param {follow_up_required "f"}
    @param {info_used_list ""}
    @param submit
    @param  return_to_issue

    @author
    @creation-date
    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} { 
    open_date_str:optional
    interaction_type:optional
    interaction_type_other:optional
    interaction_originator:optional
    first_names:optional
    last_name:optional
    email:optional
    postal_code:optional
    other_id_info:optional
    d_user_id:optional
    d_user_identification_id:optional
    interaction_id:optional 
    c_user_identification_id:optional
    postal_code:optional
    order_id:naturalnum,optional
    issue_type:optional,multiple
    issue_id:naturalnum,optional
    action_details:notnull
    action_id:notnull,naturalnum
    close_issue_p
    {issue_type_list "" }
    {follow_up_required "f"}
    {info_used_list ""}
    submit
}

ad_require_permission [ad_conn package_id] admin

# doubleclick protection:
if { [db_string get_service_action_count "select count(*) from ec_customer_service_actions where action_id=:action_id"] > 0 } {
    if { $submit == "Interaction Complete" } {
	ad_returnredirect interaction-add.tcl
    } else {
	# I have to use the action_id to figure out user_identification_id
	# and interaction_id so that I can pass them to interaction-add-2.tcl
	set row_exists_p [db_0or1row get_user_id_info "select i.user_identification_id as c_user_identification_id, a.interaction_id
	from ec_customer_service_actions a, ec_customer_serv_interactions i
	where i.interaction_id=a.interaction_id
	and a.action_id=:action_id"]
	set insert_id 1
	ad_returnredirect "interaction-add-2.tcl?[export_url_vars interaction_id interaction_type postal_code c_user_identification_id insert_id interaction_originator]"
    }
    ad_script_abort
}

# the customer service rep must be logged on

set customer_service_rep [ad_get_user_id]

if {$customer_service_rep == 0} {
    set return_url "[ad_conn url]?[export_entire_form_as_url_vars]"
    ad_returnredirect "/register.tcl?[export_url_vars return_url]"
    ad_script_abort
}

# error checking
# what matters for the logic of the customer service system:
# 1. that we don't have more than one d_user_id or d_user_identification_id
#    (it's ok to have zero -- then a new user_identification_id will be generated,
#     unless c_user_identification_id exists)
# 2. if this is based on a previous issue_id, then issue_id must be valid and
#    issue ownership must be consistent
# 3. if this is based on a previous order, then order_id must be valid and 
#    order ownership must be consistent

set exception_count 0
set exception_text ""

# first some little checks on the input data

# issue_id and order_id should be numbers and action_details should be non-empty

if { [regexp "\[^0-9\]+" $issue_id] } {
    incr exception_count
    append exception_text "<li>The issue ID should be numeric.\n"
}

if { [info exists order_id] && [regexp "\[^0-9\]+" $order_id] } {
    incr exception_count
    append exception_text "<li>The order ID should be numeric.\n"
}



if { $exception_count > 0 } {
    ad_return_complaint $exception_count $exception_text
    ad_script_abort
}

# now for the painful checks



# consistent issue ownership

# If it's the first time through, give them the chance of matching up a 
# user with the interaction based on issue_id or order_id.
# Otherwise, the user_identification_id is set, so they will just be
# given an error message.
if { ![empty_string_p $issue_id] } {
    # see who this issue belongs to
    if { [db_0or1row get_user_issue_id_info "select u.user_id as issue_user_id, u.user_identification_id as issue_user_identification_id
    from ec_user_identification u, ec_customer_service_issues i
    where u.user_identification_id = i.user_identification_id
    and i.issue_id=:issue_id"]==0 } {

	ad_return_complaint 1 "<li>The issue ID that you specified is invalid.  Please go back and check the issue ID you entered.  If this is a new issue, please leave the issue ID blank.\n"
        ad_script_abort
    }
    

    if { ![info exists c_user_identification_id] } {
	# if the issue has a user_id associated with it and d_user_id doesn't exist or match
	# the associated user_id, then give them a message with the chance to make them match
	if { ![empty_string_p $issue_user_id] } {
	    if { ![info exists d_user_id] || [string compare $d_user_id $issue_user_id] != 0 } {
		
		append doc_body "[ad_admin_header "User Doesn't Match Issue"]
		<h2>User Doesn't Match Issue</h2>
		[ad_context_bar [list "../index.tcl" "Ecommerce([ec_system_name])"] [list "index.tcl" "Customer Service Administration"] "New Interaction"]
		
		<hr>
		Issue ID $issue_id belongs to the registered user <a href=\"[ec_acs_admin_url]users/one?user_id=$issue_user_id\">[db_string get_full_name "select first_names || ' ' || last_name from cc_users where user_id=:issue_user_id"]</a>.
		
		<p>
		
		However, you haven't selected that user as the customer involved in this interaction.
		
		<p>
		
		Would you like to make this user be the owner of this interaction?  (If not, push Back and fix the issue ID.)
		
		<form method=post action=interaction-add-3>
		[ec_hidden_input "d_user_id" $issue_user_id]
		[ec_export_entire_form_except d_user_id d_user_identification_id]
		<center>
		<input type=submit value=\"Yes\">
		</center>
		</form>
		
		[ad_admin_footer]
		"
                ad_script_abort
	    }
	} elseif { ![info exists d_user_identification_id] || [string compare $d_user_identification_id $issue_user_identification_id] != 0 } {
	    # if d_user_identification_id doesn't match the issue's user_identification_id, give
	    # them a message with the chance to make them match

	    
	    append doc_body "[ad_admin_header "User Doesn't Match Issue"]
	    <h2>User Doesn't Match Issue</h2>
	    [ad_context_bar [list "../index.tcl" "Ecommerce([ec_system_name])"] [list "index.tcl" "Customer Service Administration"] "New Interaction"]
	    
	    <hr>
	    Issue ID $issue_id belongs to the the non-registered person who has had a previous interaction with us: [ec_user_identification_summary $issue_user_identification_id]
	    
	    <p>
	    
	    However, you haven't selected that user as the customer involved in this interaction.
	    
	    <p>
	    
	    Would you like to make this user be the owner of this interaction?  (If not, push Back and fix the issue ID.)
	    
	    <form method=post action=interaction-add-3>
	    [ec_hidden_input "d_user_identification_id" $issue_user_identification_id]
	    [ec_export_entire_form_except d_user_id d_user_identification_id]
	    <center>
	    <input type=submit value=\"Yes\">
	    </center>
	    </form>
	    
	    [ad_admin_footer]
	    "
            ad_script_abort
	}

    } else {
	# non-new interaction; user_identification_id fixed
	# if the issue has a user_id, then the user_id associated with user_identification_id should match.
	# since it's possible for the same user to be represented by more than one user_identification_id,
	# we can't require that they match, although it is unfortunate if they don't (but it's too late to
	# do anything about it at this point -- I should make some way to combine user_identifications)
	if { ![empty_string_p $issue_user_id] } {
	    # find out the user_id associated with c_user_identification_id
	    set c_user_id [db_string get_user_id "select user_id from ec_user_identification where user_identification_id=:c_user_identification_id"]
	    # if the c_user_id is null, they should be told about the option of matching up a user_id with
	    # user_identification_id
	    # otherwise, if the issue doesn't belong to them, they just get a plain error message
	    if { [empty_string_p $c_user_id] } {
		ad_return_complaint 1 "The issue ID you specified belongs to the registered user
		<a href=\"[ec_acs_admin_url]users/one?user_id=$issue_user_id\">[db_string get_full_name "select first_names || ' ' || last_name from cc_users where user_id=:issue_user_id"]</a>.  However, you haven't associated this interaction with any registered user.  You've associated it with the unregistered user [ec_user_identification_summary $c_user_identification_id].  If these are really the same user, match them up by clicking on the \"user info\" link and then you can reload this page without getting this error message." 
                ad_script_abort
	    } elseif { [string compare $c_user_id $issue_user_id] != 0 } {
		ad_return_complaint 1 "The issue ID you specified does not belong to the user you specified."
                ad_script_abort
	    }
	}
    }
}

# 3. consistent order ownership
if { [info exists order_id] && ![empty_string_p $order_id] } {
    # see who the order belongs to
    set row_exists_p [db_0or1row get_order_owner "select user_id as order_user_id from ec_orders where order_id=:order_id"]
    if { $row_exists_p==0 } {
	ad_return_complaint 1 "<li>The order ID that you specified is invalid.  Please go back and check the order ID you entered.  If this issue is not about a specific order, please leave the order ID blank.\n"
        ad_script_abort
    }
    

    if { ![empty_string_p $order_user_id] } {

	if { ![info exists interaction_id] } {
	    if { ![info exists d_user_id] || [string compare $d_user_id $order_user_id] != 0 } {
		
		
		append doc_body "[ad_admin_header "User Doesn't Match Order"]
		<h2>User Doesn't Match Order</h2>
		[ad_context_bar [list "../index.tcl" "Ecommerce([ec_system_name])"] [list "index.tcl" "Customer Service Administration"] "New Interaction"]
		
		<hr>
		Order ID $order_id belongs to the registered user <a href=\"[ec_acs_admin_url]users/one?user_id=$order_user_id\">[db_string get_user_name "select first_names || ' ' || last_name from cc_users where user_id=:order_user_id"]</a>.
		
		<p>
		
		However, you haven't selected that user as the customer involved in this interaction.
		
		<p>
		
		Would you like to make this user be the owner of this interaction?  (If not, push Back and fix the order ID.)
		
		<form method=post action=interaction-add-3>
		[ec_hidden_input "d_user_id" $order_user_id]
		[ec_export_entire_form_except d_user_id d_user_identification_id]
		<center>
		<input type=submit value=\"Yes\">
		</center>
		</form>
		
		[ad_admin_footer]
		"
                ad_script_abort
	    }
	} else {
	    # interaction_id exists
	    # find out the user_id associated with c_user_identification_id
	    set c_user_id [db_string get_user_id_user "select user_id from ec_user_identification where user_identification_id=:c_user_identification_id"]
	    # if the c_user_id is null, they should be told about the option of matching up a user_id with
	    # user_identification_id
	    # otherwise, if the order doesn't belong to them, they just get a plain error message
	    if { [empty_string_p $c_user_id] } {
		ad_return_complaint 1 "The order ID you specified belongs to the registered user
		<a href=\"[ec_acs_admin_url]users/one?user_id=$order_user_id\">[db_stringget_user_full_name "select first_names || ' ' || last_name from cc_users where user_id=:order_user_id"]</a>.  However, you haven't associated this interaction with any registered user.  You've associated it with the unregistered user [ec_user_identification_summary $c_user_identification_id].  If these are really the same user, match them up by clicking on the \"user info\" link and then you can reload this page without getting this error message." 
                ad_script_abort
	    } elseif { [string compare $c_user_id $order_user_id] != 0 } {
		ad_return_complaint 1 "The order ID you specified does not belong to the user you specified."
                ad_script_abort
	    }
	
	}
    }
    # Otherwise, the order is in_basket (that's why it has no user_id associated with it).
    # If the user_identification_id has a user_id associated with it, we should
    # probably give them them opportunity of sticking that into the ec_orders
    # table
    # but maybe that's giving them too much power to mess things up, so I guess not
}

# done error checking


if { [info exists interaction_id] } {
    # then the open_date didn't get passed along to this
    # script (but we need it for new customer service issues)
    set open_date_str [db_string get_interaction_date "select to_char(interaction_date, 'YYYY-MM-DD HH24:MI:SS') as open_date_str from ec_customer_serv_interactions where interaction_id=:interaction_id"]
}

# create the sql string for inserting open_date
#set date_string "to_date(:open_date_str,'YYYY-MM-DD HH24:MI:SS')"
set date_string [db_map date_string_sql]

if { [info exists interaction_id] } {
    set create_new_interaction_p "f"
} else {
    set create_new_interaction_p "t"
}

db_transaction {

# I. Have to generate:
#   1. interaction_id, unless it already exists
#   2. issue_id, unless it already exists

# interaction_id will either be a number or it will not exist
if { ![info exists interaction_id] } {
    set interaction_id [db_nextval ec_interaction_id_sequence]
}

# issue_id will either be a number or it will be the empty string
if { [empty_string_p $issue_id] } {
    set issue_id [db_nextval ec_issue_id_sequence]
    set create_new_issue_p "t"
} else {
    set create_new_issue_p "f"
}

# II. User identification (first time through):
#   1. If we have d_user_id, see if there's a user_identification with that user_id
#   2. Otherwise, see if we have d_user_identification_id
#   3. Otherwise, create a new user_identification_id

if { $create_new_interaction_p == "t" && ![info exists c_user_identification_id] } {
    if { [info exists d_user_id] } {
	db_0or1row get_uiid_to_insert "select user_identification_id as uiid_to_insert from ec_user_identification where user_id=:d_user_id"
    }
    if { ![info exists uiid_to_insert] } {
	if { [info exists d_user_identification_id] } {
	    set uiid_to_insert $d_user_identification_id
	} else {
	    set user_id_to_insert ""
	    if { [info exists d_user_id] } {
		set user_id_to_insert $d_user_id
	    }
	    
	    set uiid_to_insert [db_nextval ec_user_ident_id_sequence]
	    db_dml insert_new_uiid "insert into ec_user_identification
	    (user_identification_id, user_id, email, first_names, last_name, postal_code, other_id_info)
	    values
	    (:uiid_to_insert, :user_id_to_insert, :email,:first_names,:last_name,:postal_code,:other_id_info)
	    "
	}
    }
} else {
    set uiid_to_insert $c_user_identification_id
}
#    doc_return  200 text/html "<B>three: UTI:  $uiid_to_insert</B>" 

# III. Interaction (only if this is the first time through):
#   Have to insert into ec_customer_serv_interactions:
#   1. interaction_id
#   2. customer_service_rep
#   3. user_identification_id (= uiid_to_insert determined in II)
#   4. interaction_date (= open_date)
#   5. interaction_originator
#   6. interaction_type (=  interaction_type or interaction_type_other)

if { $create_new_interaction_p == "t" } {
    db_dml insert_new_cs_interaction "insert into ec_customer_serv_interactions
    (interaction_id, customer_service_rep, user_identification_id, interaction_date, interaction_originator, interaction_type)
    values
    (:interaction_id, :customer_service_rep, :uiid_to_insert, $date_string, :interaction_originator, [ec_decode $interaction_type "other" ":interaction_type_other" ":interaction_type"])
    "
}

# IV. Issue (unless we already have an issue):
#   1. Have to insert into ec_customer_service_issues:
#     A. issue_id (passed along or generated)
#     B. user_identification_id (= uiid_to_insert determined in II)
#     C. order_id
#     D. open_date
#     E. close_date (=null if close_issue_p=f, =open_date if close_issue_p=t)
#     F. closed_by (=null if close_issue_p=f, =customer_service_rep if close_issue_p=t)
#   2. Have to insert into ec_cs_issue_type_map:
#     issue_id & issue_type for each issue_type in issue_type_list

if { $create_new_issue_p == "t" } {
    if { $close_issue_p == "t" } {
	set customer_service_rep_bit :customer_service_rep
	set close_date $date_string
    } else {
	set customer_service_rep_bit [db_map customer_service_rep_bit_null_sql]
	set close_date [db_map close_date_null_sql]
    }
    db_dml insert_new_ec_cs_issue "insert into ec_customer_service_issues
    (issue_id, user_identification_id, order_id, open_date, close_date, closed_by)
    values
    (:issue_id, :uiid_to_insert, :order_id, $date_string, $close_date, $customer_service_rep_bit)
    "
    
    foreach issue_type $issue_type_list {
	db_dml insert_into_issue_tm "insert into ec_cs_issue_type_map
	(issue_id, issue_type)
	values
	(:issue_id, :issue_type)
	"
    }
}

# V. Action:
#  1. Have to insert into ec_customer_service_actions:
#     A. action_id
#     B. issue_id (passed along or generated)
#     C. interaction_id (generated in II)
#     D. action_details
#     E. follow_up_required
#  2. Have to insert into ec_cs_action_info_used_map:
#     action_id and info_used for each info_used in info_used_list   

db_dml insert_new_ec_service_action "insert into ec_customer_service_actions
(action_id, issue_id, interaction_id, action_details, follow_up_required)
values
(:action_id, :issue_id, :interaction_id, :action_details,:follow_up_required)
"

foreach info_used $info_used_list {
    db_dml insert_into_cs_action_info_map "insert into ec_cs_action_info_used_map
    (action_id, info_used)
    values
    (:action_id, :info_used)
    "
}

}

if { $submit == "Interaction Complete" } {
    if { ![info exists return_to_issue] } {
	ad_returnredirect interaction-add
    } else {
	ad_returnredirect "issue?issue_id=$return_to_issue"
    }
} else {
    # (in c_user_identification_id, "c" stands for "confirmed" meaning
    # that they've been through interaction-add-3.tcl and now they cannot change
    # the user_identification_id)
    set insert_id 1
    ad_returnredirect "interaction-add-2?[export_url_vars interaction_id interaction_type postal_code return_to_issue insert_id interaction_originator]&c_user_identification_id=$uiid_to_insert"
}





