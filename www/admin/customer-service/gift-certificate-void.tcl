# gift-certificate-void.tcl
ad_page_contract {
    @param gift_certificate_id
    @author
    @creation-date
    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    gift_certificate_id
}

ad_require_permission [ad_conn package_id] admin

set customer_service_rep [ad_get_user_id]

if {$customer_service_rep == 0} {
    set return_url "[ad_conn url]?[export_entire_form_as_url_vars]"
    ad_returnredirect "/register.tcl?[export_url_vars return_url]"
    ad_script_abort
}

set title "Void Gift Certificate"
set context [list [list index "Customer Service"] $title]

set export_form_vars_html [export_form_vars gift_certificate_id]
