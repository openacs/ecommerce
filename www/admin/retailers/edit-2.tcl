#  www/[ec_url_concat [ec_url] /admin]/retailers/edit-2.tcl
ad_page_contract { 
    @param retailer_id
    @param retailer_name
    @param primary_contact_name
    @param secondary_contact_name
    @param primary_contact_info
    @param secondary_contact_info
    @param line1
    @param line2
    @param city 
    @param usps_abbrev
    @param zip_code
    @param phone
    @param fax
    @param url
    @param country_code
    @param reach
    @param nexus_states
    @param financing_policy
    @param return_policy
    
    @param price_guarantee_policy
    @param delivery_policy
    @param installation_policy


  @author
  @creation-date
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    retailer_id 
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
    nexus_states:multiple
    financing_policy
    return_policy
    
    price_guarantee_policy
    delivery_policy
    installation_policy


}

ad_require_permission [ad_conn package_id] admin

# we need them to be logged in
set user_id [ad_conn user_id]

if {$user_id == 0} {
    
    set return_url "[ad_conn url]?[export_entire_form_as_url_vars]"

    ad_returnredirect "/register.tcl?[export_url_vars return_url]"
    ad_script_abort
}

set audit_update "last_modified=sysdate, last_modifying_user=:user_id, modified_ip_address=[ns_dbquotevalue [ns_conn peeraddr]]"



db_dml unused "
update ec_retailers
   set retailer_name=:retailer_name, 
       primary_contact_name=:primary_contact_name, 
       secondary_contact_name=:secondary_contact_name, 
       primary_contact_info=:primary_contact_info, 
       secondary_contact_info=:secondary_contact_info, 
       line1=:line1, 
       line2=:line2, 
       city=:city, 
       usps_abbrev=:usps_abbrev, 
       zip_code=:zip_code, 
       phone=:phone, 
       fax=:fax, 
       url=:url, 
       country_code=:country_code, 
       reach=:reach, 
       nexus_states=:nexus_states, 
       financing_policy=:financing_policy, 
       return_policy=:return_policy, 
       price_guarantee_policy=:price_guarantee_policy, 
       delivery_policy=:delivery_policy, 
       installation_policy=:installation_policy, 
       $audit_update
where retailer_id=:retailer_id
"
db_release_unused_handles
ad_returnredirect index.tcl
