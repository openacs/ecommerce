#  www/[ec_url_concat [ec_url] /admin]/retailers/add-3.tcl
ad_page_contract {
  This page inserts the new retailer's info into database.

  @author
  @creation-date
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    retailer_id:naturalnum
    retailer_name
    primary_contact_name
    secondary_contact_name
    primary_contact_info
    secondary_contact_info
    line1
    line2
    city
    usps_abbrev
    zip_code
    phone
    fax
    url
    country_code
    reach
    nexus_states
    financing_policy
    return_policy
    price_guarantee_policy
    delivery_policy
    installation_policy

}

ad_require_permission [ad_conn package_id] admin

# 
# we need them to be logged in
set user_id [ad_conn user_id]

if {$user_id == 0} {
    
    set return_url "[ad_conn url]?[export_entire_form_as_url_vars]"

    ad_returnredirect "/register.tcl?[export_url_vars return_url]"
    ad_script_abort
}



# we have to generate audit information
set audit_fields "last_modified, last_modifying_user, modified_ip_address"
set audit_info "sysdate, :user_id, [ns_dbquotevalue [ns_conn peeraddr]]"

db_dml insert_new_retailer "insert into ec_retailers
(retailer_id, retailer_name, primary_contact_name, secondary_contact_name, primary_contact_info, secondary_contact_info, line1, line2, city, usps_abbrev, zip_code, phone, fax, url, country_code, reach, nexus_states, financing_policy, return_policy, price_guarantee_policy, delivery_policy, installation_policy, $audit_fields)
values 
(:retailer_id, :retailer_name, :primary_contact_name, :secondary_contact_name, :primary_contact_info, :secondary_contact_info, :line1, :line2, :city, :usps_abbrev, :zip_code, :phone, :fax, :url, :country_code, :reach, :nexus_states, :financing_policy, :return_policy, :price_guarantee_policy, :delivery_policy, :installation_policy, $audit_info)
"
db_release_unused_handles
ad_returnredirect index.tcl
