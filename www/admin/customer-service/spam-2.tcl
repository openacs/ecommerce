# spam-2.tcl

ad_page_contract {
    @param mailing_list:optional
    @param user_class_id:optional
    @param product_sku:optional
   
    @param user_id_list:optional
    @param category_id:optional
    @param viewed_product_sku:optional

    @param show_users_p:optional

    @author
    @creation-date
    @cvs-id spam-2.tcl,v 3.3.2.9 2000/09/22 01:34:54 kevin Exp
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    mailing_list:optional
    user_class_id:optional
    product_sku:optional
    user_id_list:optional
    category_id:optional
    viewed_product_sku:optional
    show_users_p:optional
    start_date:array,date,optional
    end_date:array,date,optional
}

ad_require_permission [ad_conn package_id] admin

set return_url "[ad_conn url]?[export_entire_form_as_url_vars]"

set customer_service_rep [ad_get_user_id]

if {$customer_service_rep == 0} {
    ad_returnredirect "/register.tcl?[export_url_vars return_url]"
    return
}

append doc_body "[ad_admin_header "Spam Users, Cont."]
<h2>Spam Users, Cont.</h2>

[ad_admin_context_bar [list "../index.tcl" "Ecommerce([ec_system_name])"] [list "index.tcl" "Customer Service Administration"] "Spam Users, Cont."]

<hr>
"

if { [info exists show_users_p] && $show_users_p == "t" } {
    if { [info exists user_id_list] } {
        set sql [db_map mailing_list]
	# select user_id, first_names, last_name from cc_users where user_id in ([join $user_id_list ", "])
    } elseif { [info exists mailing_list] } {
        if { [llength $mailing_list] == 0 } {
            set search_criteria [db_map null_categories]
	    # (category_id is null and subcategory_id is null and subsubcategory_id is null)
        } elseif { [llength $mailing_list] == 1 } {
            set search_criteria [db_map null_subcategory]
	    # (category_id=$mailing_list and subcategory_id is null)
        } elseif { [llength $mailing_list] == 2 } {
            set search_criteria [db_map null_subsubcategory]
	    # (subcategory_id=[lindex $mailing_list 1] and subsubcategory_id is null)
        } else {
            set search_criteria [db_map subsubcategory]
	    # subsubcategory_id=[lindex $mailing_list 2]
        }
        set sql "[db_map null_categories] and $search_criteria"
	# select users.user_id, first_names, last_name from cc_users, ec_cat_mailing_lists where users.user_id=ec_cat_mailing_lists.user_id
    } elseif { [info exists user_class_id] } {
        if { ![empty_string_p $user_class_id]} {
            set sql [db_map user_class]
	    # select users.user_id, first_names, last_name from cc_users, ec_user_class_user_map m where m.user_class_id=:user_class_id and m.user_id=users.user_id
        } else {
            set sql [db_map all_users]
            # select user_id, first_names, last_name from cc_users
        }
    } elseif { [info exists product_sku] } {
        set sql [db_map bought_product]
        # select unique cc_users.user_id, first_names, last_name from cc_users, ec_items, ec_orders where ec_items.order_id=ec_orders.order_id and ec_orders.user_id=ccusers.user_id and ec_items.sku=:product_sku
    } elseif { [info exists viewed_product_sku] } {
        set sql [db_map viewed_product]
        # select unique u.user_id, first_names, last_name from cc_users u, ec_user_session_info ui, ec_user_sessions us where us.user_session_id=ui.user_session_id and us.user_id=u.user_id and ui.sku=:viewed_product_sku
    } elseif { [info exists category_id] } {
        set sql [db_map viewed_category]
        # select unique u.user_id, first_names, last_name from cc_users u, ec_user_session_info ui, ec_user_sessions us where us.user_session_id=ui.user_session_id and us.user_id=u.user_id and ui.category_id=:category_id
    } elseif { [info exists start_date] } {
	set start $start_date(date)
	set end $end_date(date)
        set sql [db_map last_visit]
        # select user_id, first_names, last_name from cc_users where last_visit >= to_date(:start,'YYYY-MM-DD HH24:MI:SS') and last_visit <= to_date(:end,'YYYY-MM-DD HH24:MI:SS')
    } else {

	set start ""
	set end ""
        ad_return_complaint 1 "<li>I could not determine who you wanted to spam.  Please go back and make a selection."
        return

    }

    append doc_body "The following users will be spammed:
    <ul>"

    db_foreach get_users_for_spam $sql {
        
        append doc_body "<li><a href=\"[ec_acs_admin_url]users/one?user_id=$user_id\">$first_names $last_name</a>\n"
    }
    append doc_body "</ul>"
}

set spam_id [db_nextval ec_spam_id_sequence]

# will export start_date and end_date separately so that they don't have to be re-put-together
# in spam-3.tcl
append doc_body "
<form method=post action=../tools/spell>
[ec_hidden_input var_to_spellcheck "message"]
[ec_hidden_input target_url "[ec_url_concat [ec_url] /admin]/customer-service/spam-3.tcl"]
[export_entire_form]
[export_form_vars spam_id start end]
<table border=0 cellspacing=0 cellpadding=10>
<tr>
<td>From</td>
<td>[ad_parameter -package_id [ec_id] CustomerServiceEmailAddress ecommerce]</td>
</tr>
<tr><td>Subject Line</td><td><input type=text name=subject size=30></td></tr>
<tr><td valign=top>Message</td><td><TEXTAREA wrap=hard name=message COLS=50 ROWS=15></TEXTAREA></td></tr>
<tr>
<td>Gift Certificate*</td>
<td>Amount <input type=text name=amount size=5> ([ad_parameter -package_id [ec_id] Currency ecommerce]) &nbsp; &nbsp; Expires [ec_gift_certificate_expires_widget "in 1 year"]</td>
</tr>
<tr><td valign=top>Issue Type**</td><td valign=top>[ec_issue_type_widget "spam"]</td></tr>
</table>
<p>
<center>
<input type=submit value=\"Send\">
</center>
</form>

* Note: You can optionally issue a gift certificate to each user you're spamming (if you don't want to, just leave the amount blank).
<p>
** Note: A customer service issue is created whenever an email is sent. The issue is automatically closed unless the customer replies to the issue, in which case it is reopened.

[ad_admin_footer]
"

doc_return  200 text/html $doc_body