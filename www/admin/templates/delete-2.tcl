#  www/[ec_url_concat [ec_url] /admin]/templates/delete-2.tcl
ad_page_contract {
    @param template_id

  @author
  @creation-date
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    template_id:integer
}

ad_require_permission [ad_conn package_id] admin

# check if this is the template that the admin has assigned as the default
# in which case they'll have to select a new default before they can delete
# this one


set default_template_id [db_string get_default_template "select default_template
from ec_admin_settings"]

if { $template_id == $default_template_id } {
    ad_return_complaint 1 "You cannot delete this template because it is the default template that 
    products will be displayed with if they are not set to be displayed with a different template.
    <p>
    If you want to delete this template, you can do so by first setting a different template to
    be the default template.  (To do this, go to a different template and click \"Make this template
    be the default template\".)"
    ad_script_abort
}

set user_id [ad_conn user_id]

if {$user_id == 0} {
    
    set return_url "[ad_conn url]?[export_url_vars template_id]"

    ad_returnredirect "/register?[export_url_vars return_url]"
    ad_script_abort
}


db_transaction {

# we have to first remove all references to this template in ec_products and ec_category_template_map

db_dml delete_product_refs "update ec_products set template_id=null, last_modified=sysdate, last_modifying_user=:user_id, modified_ip_address=[ns_dbquotevalue [ns_conn peeraddr]] where template_id=:template_id"

db_dml delete_from_ec_template_map "delete from ec_category_template_map where template_id=:template_id"

db_dml delete_from_ec_templates "delete from ec_templates where template_id=:template_id"
ec_audit_delete_row [list $template_id] [list template_id] ec_templates_audit

}
db_release_unused_handles

ad_returnredirect index

