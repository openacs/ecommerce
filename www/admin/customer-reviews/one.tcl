# one.tcl

ad_page_contract {
    @param comment_id
    @author
    @creation-date
    @cvs-id one.tcl,v 3.1.6.6 2000/09/22 01:34:50 kevin Exp
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    comment_id:naturalnum,notnull
}

ad_require_permission [ad_conn package_id] admin

append doc_body "[ad_admin_header "One Review"]

<h2>One Review</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index.tcl" "Customer Reviews"] "One Review"]

<hr>
<blockquote>
"


if { ![db_0or1row get_product_info "select c.product_id, c.user_id, c.user_comment, c.one_line_summary, c.rating, p.product_name, u.email, c.comment_date, c.approved_p
from ec_product_comments c, ec_products p, cc_users u
where c.product_id = p.product_id
and c. user_id = u.user_id 
and c.comment_id=:comment_id"] } {
    ad_return_complaint 1 "Invalid Comment ID passed in"
}



append doc_body "[util_AnsiDatetoPrettyDate $comment_date]<br>
<a href=\"../products/one?[export_url_vars product_id]\">$product_name</a><br>
<a href=\"[ec_acs_admin_url]users/one?[export_url_vars user_id]\">$email</a> [ec_display_rating $rating]<br>
<b>$one_line_summary</b><br>
$user_comment
<br>
"

if { [info exists product_id] } {
    # then we don't know a priori whether this is an approved review
    append doc_body "<b>Review Status: "
    if { $approved_p == "t" } {
	append doc_body "Approved</b><br>"
    } elseif { $approved_p == "f" } {
	append doc_body "Disapproved</b><br>"
    } else {
	append doc_body "Not yet Approved/Disapproved</b><br>"
    }
}

append doc_body "\[<a href=\"approval-change?approved_p=t&[export_url_vars comment_id return_url]\">Approve</a> | <a href=\"approval-change?approved_p=f&[export_url_vars comment_id return_url]\">Disapprove</a>\]

</blockquote>
[ad_admin_footer]
"
 
doc_return  200 text/html $doc_body
