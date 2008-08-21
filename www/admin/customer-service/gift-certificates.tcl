# gift-certificates.tcl
ad_page_contract {
    @param  user_id
    @author
    @creation-date
    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} { 
    user_id
}

ad_require_permission [ad_conn package_id] admin

set title "Gift Certificates"
set context [list [list index "Customer Service"] $title]

set customer_info_html "<a href=\"[ec_acs_admin_url]users/one?user_id=$user_id\">[db_string get_customer_info "select first_names || ' ' || last_name from cc_users where user_id=:user_id"]</a>"

set gift_cert_account_bal_html "[ec_pretty_price [db_string get_pretty_price "select ec_gift_certificate_balance(:user_id) from dual"]]"
set export_form_vars_html [export_form_vars user_id]
set currency [parameter::get -package_id [ec_id] -parameter Currency -default "USD"]

set gc_expires_widget_html [ec_gift_certificate_expires_widget "in 1 year"]

set sql "select c.*, i.first_names || ' ' || i.last_name as issuer, i.user_id as issuer_user_id, p.first_names || ' ' || p.last_name as purchaser, p.user_id as purchaser_user_id, gift_certificate_amount_left(c.gift_certificate_id) as amount_left, decode(sign(sysdate-expires),1,'t',0,'t','f') as expired_p, v.first_names as voided_by_first_names, v.last_name as voided_by_last_name
from ec_gift_certificates c, cc_users i, cc_users p, cc_users v
where c.issued_by=i.user_id(+)
and c.purchased_by=p.user_id(+)
and c.voided_by=v.user_id(+)
and c.user_id=:user_id
order by expired_p, decode(amount_left,0,1,0), decode(gift_certificate_state,'void',1,0), gift_certificate_id"

set gift_certificate_counter 0
set current_printed 0
set old_printed 0
set gift_certs_for_users_html
db_foreach get_gift_certificates_for_user $sql {
    if { $current_printed == 0 && $expired_p == "f" && $amount_left > 0 && $gift_certificate_state != "void"} {
        append gift_certs_for_users_html "<p><b>Currently Available Gift Certificates</b></p>"
        set current_printed 1
    } elseif { $old_printed == 0 && ($expired_p == "t" || $amount_left == 0 || $gift_certificate_state == "void") } {
        if { $current_printed == 1 } {
            # do nothing
        }
        append gift_certs_for_users_html "<p><b>Expired or Usded Gift Certificates</b></p>"
        set old_printed 1
    }
    incr gift_certificate_counter

    append gift_certs_for_users_html "<table>\n<tr><td>Gift Certificate ID &nbsp;&nbsp;&nbsp;</td><td>$gift_certificate_id"
    if { $expired_p == "f" && $amount_left > 0 && $gift_certificate_state != "void"} {
        append gift_certs_for_users_html "  (<a href=\"gift-certificate-void?[export_url_vars gift_certificate_id]\">void this</a>) "
    }
    append gift_certs_for_users_html "</td></tr>
    <tr><td>Amount Left</td><td>[ec_pretty_price $amount_left] (out of [ec_pretty_price $amount])</td></tr>
    <tr><td>Issue Date</td><td>[util_AnsiDatetoPrettyDate $issue_date]</td></tr>\n"
    if { ![empty_string_p $issuer_user_id] } {
        append gift_certs_for_users_html "<tr><td>Issued By</td><td><a href=\"[ec_acs_admin_url]users/one?user_id=$issuer_user_id\">$issuer</a></td></tr>\n"
    } else {
        append gift_certs_for_users_html "<tr><td>Purchased By</td><td><a href=\"[ec_acs_admin_url]users/one?user_id=$purchaser_user_id\">$purchaser</a></td></tr>\n"
    }
    append gift_certs_for_users_html "<tr><td>[ec_decode $expired_p "t" "Expired" "Expires"]</td><td>[ec_decode $expires "" "never" [util_AnsiDatetoPrettyDate $expires]]</td></tr>\n"
    if { $gift_certificate_state == "void" } {
        append gift_certs_for_users_html "<tr><td><b>Voided</td><td>[util_AnsiDatetoPrettyDate $voided_date] by <a href=\"[ec_acs_admin_url]users/one?user_id=$voided_by\">$voided_by_first_names $voided_by_last_name</a> because: $reason_for_void</td></tr>\n"
    }
    append gift_certs_for_users_html "</table><br>"
}

