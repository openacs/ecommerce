# /tcl/ecommerce-customer-service.tcl
ad_library {

    Customer service procedures for the ecommerce module 

    @author Eve Andersson (eveander@arsdigita.com)
    @creation-date 1 April 1999
    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)

}

ad_proc ec_customer_service_email_address { {user_identification_id ""} {issue_id ""}} { returns the customer server email address } {
    return [ad_parameter -package_id [ec_id] CustomerServiceEmailAddress ecommerce]
}

ad_proc ec_customer_service_signature {-html:boolean} {
    if $html_p {
        return "[ad_parameter -package_id [ec_id] CustomerServiceEmailDescription ecommerce]<br>
[ad_parameter -package_id [ec_id] CustomerServiceEmailAddress ecommerce]<br>
[ec_insecure_location][ec_url]
"
    } else {
        return "[ad_parameter -package_id [ec_id] CustomerServiceEmailDescription ecommerce]
[ad_parameter -package_id [ec_id] CustomerServiceEmailAddress ecommerce]
[ec_insecure_location][ec_url]
"
    }
}

ad_proc ec_customer_service_simple_issue { customer_service_rep interaction_originator interaction_type interaction_headers order_id issue_type_list action_details {user_id ""} {user_identification_id ""} {begin_new_transaction_p "f"} {gift_certificate_id ""} } { 
 Creates an issue, interaction, and action and closes the issue.
 Either user_id or user_identification_id should be non-null.
 Often ec_customer_service_simple_issue is called from another
 procedure within a transaction, so you will not want to begin/end
 a transaction within ec_customer_service_simple_issue.  In these
 cases, leave begin_new_transaction_p as "f".

 (Seb 20000817) Since Oracle driver now supports nested transactions
 we will, for the time being, simply ignore begin_new_transaction_p.
} {
    set issue_id [db_string get_ec_issue_seq "select ec_issue_id_sequence.NEXTVAL from dual"]

    if { ![empty_string_p $user_id] } {
	    
	db_foreach user_identification_select {
	    select user_identification_id from ec_user_identification where user_id = :user_id
	} {
	    break
	}
	
	if { [empty_string_p $user_identification_id] } {
	    # no previous customer service interaction with this user, so
	    # insert them into ec_user_identification
	    set user_identification_id [db_nextval "ec_user_ident_id_sequence"]
	    db_dml user_identification_insert {
                insert into ec_user_identification
		(user_identification_id, user_id)
                values
		(:user_identification_id, :user_id)
            }
	}
    }

    # now we have a non-null user_identification_id to use in the issue/interaction
    
    set interaction_id [db_nextval "ec_interaction_id_sequence"]

    db_dml customer_service_interaction_insert {
	insert into ec_customer_serv_interactions
	(interaction_id, customer_service_rep, user_identification_id, interaction_date, interaction_originator, interaction_type, interaction_headers)
	values
	(:interaction_id, :customer_service_rep, :user_identification_id, sysdate, :interaction_originator, :interaction_type, :interaction_headers)
    }

    set issue_id [db_nextval "ec_issue_id_sequence"]

    db_dml customer_service_issue_insert {
        insert into ec_customer_service_issues
	(issue_id, user_identification_id, order_id, open_date, close_date, closed_by, gift_certificate_id)
        values
	(:issue_id, :user_identification_id, :order_id, sysdate, sysdate, :customer_service_rep, :gift_certificate_id)
    }
   
    foreach issue_type $issue_type_list {
	db_dml issue_type_map_insert {
            insert into ec_cs_issue_type_map
	    (issue_id, issue_type)
            values
	    (:issue_id, :issue_type)
	}
    }
    
    set action_id [db_nextval "ec_action_id_sequence"]

    db_dml customer_service_action_insert {
        insert into ec_customer_service_actions
	(action_id, issue_id, interaction_id, action_details)
        values
	(:action_id, :issue_id, :interaction_id, :action_details)
    }


    # since the interaction and action are done with, the important things to return are
    # the user_identification_id and the issue_id
    
  
    return [list $user_identification_id $issue_id]
}

ad_proc ec_all_cs_issues_by_one_user { {user_id ""} {user_identification_id ""} } { lists all issues by user_id or user_identification } {
    set to_return "<ul>"

    if { ![empty_string_p $user_id] } {

	set sql {
	    select i.issue_id, i.open_date, i.close_date, m.issue_type
	    from ec_customer_service_issues i, ec_cs_issue_type_map m, ec_user_identification id
	    where i.issue_id = m.issue_id(+)
	    and i.user_identification_id = id.user_identification_id
	    and id.user_id = :user_id
	    order by i.issue_id
	}

    } else {

	set sql {
	    select i.issue_id, i.open_date, i.close_date, m.issue_type
	    from ec_customer_service_issues i, ec_cs_issue_type_map m
	    where i.issue_id = m.issue_id(+)
	    and i.user_identification_id = :user_identification_id
	    order by i.issue_id
	}
    }

    set old_issue_id ""
    set issue_type_list [list]

    db_foreach user_customer_service_issue $sql {

	if { $issue_id != $old_issue_id } {
	    if { [llength $issue_type_list] > 0 } {
		append to_return " ([join $issue_type_list ", "])"
		set issue_type_list [list]
	    }
	    append to_return "<li> <a href=\"[ec_url_concat [ec_url] /admin]/customer-service/issue?[export_vars issue_id]\">$issue_id</a>: opened [util_AnsiDatetoPrettyDate $open_date]"
	    if { ![empty_string_p $close_date] } {
		append to_return ", closed [util_AnsiDatetoPrettyDate $close_date]"
	    }
	}
	if { ![empty_string_p $issue_type] } {
	    lappend issue_type_list $issue_type
	}
	set old_issue_id $issue_id
    }

    if { [llength $issue_type_list] > 0 } {
	append to_return " ([join $issue_type_list ", "])"
    }

    append to_return "</ul>"
    return $to_return
}
