# statistics.tcl

ad_page_contract {
    @author
    @creation-date
    @cvs-id statistics.tcl,v 3.1.6.4 2000/09/22 01:34:54 kevin Exp
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
}
# 
ad_require_permission [ad_conn package_id] admin

set page_title "Statistics and Reports"

append doc_body "[ad_admin_header $page_title]
<h2>$page_title</h2>

[ad_admin_context_bar [list "../index.tcl" "Ecommerce([ec_system_name])"] [list "index.tcl" "Customer Service Administration"] $page_title]

<hr>

<h3>Issues by Issue Type</h3>
<ul>
"



set important_issue_type_list [db_list get_issue_type_list "select picklist_item from ec_picklist_items where picklist_name='issue_type' order by sort_key"]

# for sorting
if { [llength $important_issue_type_list] > 0 } {
    set issue_type_decode ", decode(issue_type,"
    set issue_type_counter 0
    foreach issue_type $important_issue_type_list {
	append issue_type_decode "'[DoubleApos $issue_type]',$issue_type_counter,"
	incr issue_type_counter
    }
    append issue_type_decode "$issue_type_counter)"
} else {
    set issue_type_decode ""
}

set sql "select issue_type, count(*) as n_issues
from ec_customer_service_issues, ec_cs_issue_type_map
where ec_customer_service_issues.issue_id=ec_cs_issue_type_map.issue_id(+)
group by issue_type
order by decode(issue_type,null,1,0) $issue_type_decode"

set other_issue_type_count 0
db_foreach get_issues_type_counts $sql {
    
    if { [lsearch $important_issue_type_list $issue_type] != -1 } {
	append doc_body "<li>$issue_type: <a href=\"issues?view_issue_type=[ns_urlencode $issue_type]\">$n_issues</a>\n"
    } elseif { ![empty_string_p $issue_type] } {
	set other_issue_type_count [expr $other_issue_type_count + $n_issues]
    } else {
	if { $other_issue_type_count > 0 } {
	    append doc_body "<li>all others: <a href=\"issues?view_issue_type=[ns_urlencode "all others"]\">$other_issue_type_count</a>\n"
	}
	if { $n_issues > 0 } {
	    append doc_body "<li>none: <a href=\"issues?view_issue_type=uncategorized\">$n_issues</a>\n"
	}
    }
}

append doc_body "</ul>

<h3>Interactions by Originator</h3>

<ul>
"

set sql "select interaction_originator, count(*) as n_interactions
from ec_customer_serv_interactions
group by interaction_originator
order by decode(interaction_originator,'customer',0,'rep',1,'automatic',2)"

db_foreach get_actions_by_originator $sql {
    
    append doc_body "<li>$interaction_originator: <a href=\"interactions?view_interaction_originator=[ns_urlencode $interaction_originator]\">$n_interactions</a>\n"
}

append doc_body "</ul>

<h3>Interactions by Customer Service Rep</h3>

<ul>
"

set sql "
  select customer_service_rep, first_names, last_name, count(*) as n_interactions
    from ec_customer_serv_interactions, cc_users
   where ec_customer_serv_interactions.customer_service_rep=cc_users.user_id
group by customer_service_rep, first_names, last_name
order by count(*) desc"

db_foreach get_actions_by_cs_rep $sql {
    
    append doc_body "<li><a href=\"[ec_acs_admin_url]users/one?user_id=$customer_service_rep\
\">$first_names $last_name</a>: <a href=\"interactions?view_rep=$customer_service_rep\">$n_interactions</a>\n"
}

append doc_body "</ul>

<h3>Actions by Info Used</h3>

<ul>
"

set important_info_used_list [db_list get_important_info_list "select picklist_item from ec_picklist_items where picklist_name='info_used' order by sort_key"]

# for sorting
if { [llength $important_info_used_list] > 0 } {
    set info_used_decode ", decode(info_used,"
    set info_used_counter 0
    foreach info_used $important_info_used_list {
	append info_used_decode "'[DoubleApos $info_used]',$info_used_counter,"
	incr info_used_counter
    }
    append info_used_decode "$info_used_counter)"
} else {
    set info_used_decode ""
}

set sql "select info_used, count(*) as n_actions
from ec_customer_service_actions, ec_cs_action_info_used_map
where ec_customer_service_actions.action_id=ec_cs_action_info_used_map.action_id(+)
group by info_used
order by decode(info_used,null,1,0) $info_used_decode"

set other_info_used_count 0
db_foreach get_info_used_query $sql {
    
    if { [lsearch $important_info_used_list $info_used] != -1 } {
	append doc_body "<li>$info_used: <a href=\"actions?view_info_used=[ns_urlencode $info_used]\">$n_issues</a>\n"
    } elseif { ![empty_string_p $info_used] } {
	set other_info_used_count [expr $other_info_used_count + $n_actions]
    } else {
	if { $other_info_used_count > 0 } {
	    append doc_body "<li>all others: <a href=\"actions?view_info_used=[ns_urlencode "all others"]\">$other_info_used_count</a>\n"
	}
	if { $n_issues > 0 } {
	    append doc_body "<li>none: <a href=\"actions?view_info_used=none\">$n_actions</a>\n"
	}
    }
}

append doc_body "</ul>
[ad_admin_footer]
"



doc_return  200 text/html $doc_body