# gift-certificate-void.tcl

ad_page_contract {
    @param gift_certificate_id
    @author
    @creation-date
    @cvs-id gift-certificate-void.tcl,v 3.2.6.4 2000/09/22 01:34:52 kevin Exp
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    gift_certificate_id
}

ad_require_permission [ad_conn package_id] admin

set customer_service_rep [ad_get_user_id]

if {$customer_service_rep == 0} {
    set return_url "[ad_conn url]?[export_entire_form_as_url_vars]"
    ad_returnredirect "/register.tcl?[export_url_vars return_url]"
    return
}



set page_title "Void Gift Certificate"
append doc_body "[ad_admin_header $page_title]
<h2>$page_title</h2>

[ad_admin_context_bar [list "../index.tcl" "Ecommerce([ec_system_name])"] [list "index.tcl" "Customer Service Administration"] $page_title]

<hr>
Please explain why you are voiding this gift certificate:

<form method=post action=gift-certificate-void-2>
[export_form_vars gift_certificate_id]

<blockquote>
<textarea wrap name=reason_for_void rows=3 cols=50></textarea>
</blockquote>

<center>
<input type=submit value=\"Continue\">
</center>

</form>

[ad_admin_footer]
"

doc_return  200 text/html $doc_body