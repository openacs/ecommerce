# /www/[ec_url_concat [ec_url] /admin]/orders/gift-certificate.tcl
ad_page_contract {

  Gift certificate page.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  gift_certificate_id:integer,notnull
}

ad_require_permission [ad_conn package_id] admin

doc_body_append "[ad_admin_header "One Gift Certificate"]

<h2>One Gift Certificate</h2>

[ad_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index" "Orders"] [list "gift-certificates" "Gift Certificates"] "One"]

<hr>
<blockquote>
"





if {![db_0or1row gift_certificate_select "
select c.*, i.first_names || ' ' || i.last_name as issuer, i.user_id as issuer_user_id, p.first_names || ' ' || p.last_name as purchaser, p.user_id as purchaser_user_id, gift_certificate_amount_left(c.gift_certificate_id) as amount_left, decode(sign(sysdate-expires),1,'t',0,'t','f') as expired_p, v.first_names as voided_by_first_names, v.last_name as voided_by_last_name, o.first_names || ' ' || o.last_name as owned_by
from ec_gift_certificates c, cc_users i, cc_users p, cc_users v, cc_users o
where c.issued_by=i.user_id(+)
and c.purchased_by=p.user_id(+)
and c.voided_by=v.user_id(+)
and c.user_id=o.user_id(+)
and c.gift_certificate_id=:gift_certificate_id
"]} {
  doc_body_append "Not Found. [ad_admin_footer]"
  return
}

doc_body_append "
<table>
<tr><td>Gift Certificate ID &nbsp;&nbsp;&nbsp;</td><td>$gift_certificate_id</td></tr>
<tr><td>Amount Left</td><td>[ec_pretty_pure_price $amount_left] <font size=-1>(out of [ec_pretty_pure_price $amount])</font></td></tr>
"
if { ![empty_string_p $issuer_user_id] } {
    doc_body_append "<tr><td>Issued By</td><td><a href=\"[ec_acs_admin_url]users/one?user_id=$issuer_user_id\">$issuer</a> on [util_AnsiDatetoPrettyDate $issue_date]</td></tr>
    <tr><td>Issued To</td><td><a href=\"[ec_acs_admin_url]users/one?user_id=$user_id\">$owned_by</a></td><tr>"
} else {
    doc_body_append "<tr><td>Purchased By</td><td><a href=\"[ec_acs_admin_url]users/one?user_id=$purchaser_user_id\">$purchaser</a> on [util_AnsiDatetoPrettyDate $issue_date]</td></tr>
    <tr><td>Sent To</td><td>$recipient_email</td></tr>
    "

    if { ![empty_string_p $user_id] } {
	doc_body_append "<tr><td>Claimed By</td><td><a href=\"[ec_acs_admin_url]users/one?user_id=$user_id\">$owned_by</a> on [util_AnsiDatetoPrettyDate $claimed_date]</td></tr>"
    }

}
doc_body_append "<tr><td>[ec_decode $expired_p "t" "Expired" "Expires"]</td><td>[ec_decode $expires "" "never" [util_AnsiDatetoPrettyDate $expires]]</td></tr>
"

if { $gift_certificate_state == "void" } {
    doc_body_append "<tr><td><font color=red>Voided</font></td><td>[util_AnsiDatetoPrettyDate $voided_date] by <a href=\"[ec_acs_admin_url]users/one?user_id=$voided_by\">$voided_by_first_names $voided_by_last_name</a> because: $reason_for_void</td></tr>"
}

doc_body_append "</table>"

if { $expired_p == "f" && $amount_left > 0 && $gift_certificate_state != "void"} {
    doc_body_append "<font size=-1>(<a href=\"gift-certificate-void?[export_url_vars gift_certificate_id]\">void this</a>)</font>
    "
}

doc_body_append "</blockquote>
[ad_admin_footer]
"
