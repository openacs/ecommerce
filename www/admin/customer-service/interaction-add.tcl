# interaction-add.tcl

ad_page_contract { 
    @param issue_id:optional
    @param user_identification_id:optional

    @author
    @creation-date
    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    issue_id:optional
    user_identification_id:optional
}

ad_require_permission [ad_conn package_id] admin

# the customer service rep must be logged on

set return_url "[ad_conn url]"

set customer_service_rep [ad_get_user_id]

if {$customer_service_rep == 0} {
    ad_returnredirect "/register?[export_url_vars return_url]"
    ad_script_abort
}

if { [info exists issue_id] } {
    set return_to_issue $issue_id
}
if { [info exists user_identification_id] } {
    set c_user_identification_id $user_identification_id
}

set insert_id 0

append doc_body "[ad_admin_header "New Interaction"]
<h2>New Interaction</h2>

[ad_context_bar [list "../index.tcl" "Ecommerce([ec_system_name])"] [list "index.tcl" "Customer Service Administration"] "New Interaction"]

<hr>

<form method=post action=interaction-add-2>
[export_form_vars issue_id return_to_issue c_user_identification_id insert_id]
<blockquote>
<table>
"



if { [info exists user_identification_id] } {
    append doc_body "<tr>
    <td>Customer:</td>
    <td>[ec_user_identification_summary $user_identification_id]</td>
    </tr>
    "
}

append doc_body "<tr>
<td>Customer Service Rep:</td>
<td>[db_string get_full_name "select first_names || ' ' || last_name from cc_users where user_id=:customer_service_rep"] (if this is wrong, please <a href=\"/register?[export_url_vars return_url]\">log in</a>)</td>
</tr>
<tr>
<td>Date &amp; Time:</td>
<td>[ad_dateentrywidget open_date] [ec_timeentrywidget open_date "[ns_localsqltimestamp]"]</td>
</tr>
<tr>
<td>Inquired via:</td>
<td>
[ec_interaction_type_widget]
</td>
</tr>
<tr>
<td>Who initiated this inquiry?</td>
<td><select name=interaction_originator>
<option value=\"customer\">customer
<option value=\"rep\">customer service rep
</select>
</td>
</tr>
</table>
</blockquote>
"

if { ![info exists user_identification_id] } {
    append doc_body "<p>
    Fill in any of the following information, which the system can use to try to identify the customer:
    <p>
    <blockquote>
    <table>
    <tr>
    <td>First Name:</td>
    <td><input type=text name=first_names size=15> Last Name: <input type=text name=last_name size=20></td>
    </tr>
    <tr>
    <td>Email Address:</td>
    <td><input type=text name=email size=30></td>
    </tr>
    <tr>
    <td>Zip Code:</td>
    <td><input type=text name=postal_code size=5 maxlength=5>
    If you fill this in, we'll determine which city/state they live in.</td>
    </tr>
    <tr>
    <td>Other Identifying Info:</td>
    <td><input type=text name=other_id_info size=30></td>
    </tr>
    </table>
    "
}

append doc_body "</blockquote>

<center>
<input type=submit value=\"Continue\">
</center>

</form>

[ad_admin_footer]
"


doc_return  200 text/html $doc_body
