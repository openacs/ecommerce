# edit-2.tcl

ad_page_contract {
    @author
    @creation-date
    @cvs-id edit-2.tcl,v 3.1.6.6 2000/08/18 21:46:59 stevenp Exp
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    tax_rate:array
    shipping_p:array
    usps_abbrev_list:notnull
}

ad_require_permission [ad_conn package_id] admin

# we need them to be logged in
set user_id [ad_verify_and_get_user_id]

if {$user_id == 0} {
    
    set return_url "[ad_conn url]?[export_entire_form_as_url_vars]"

    ad_returnredirect "/register.tcl?[export_url_vars return_url]"
    return
}


# error checking (must have a tax rate and shipping_p for each state)
set exception_count 0
set exception_text ""
foreach usps_abbrev $usps_abbrev_list {
    if { ![info exists tax_rate($usps_abbrev)] || [empty_string_p $tax_rate(${usps_abbrev})] } {
	incr exception_count
	append exception_text "<li>You forgot to enter the tax rate for [ec_state_name_from_usps_abbrev $usps_abbrev]"
    } 

    if { ![info exists shipping_p($usps_abbrev)] || [empty_string_p $shipping_p($usps_abbrev)] } {
	incr exception_count
	append exception_text "<li>You forgot to specify whether tax is charged for shipping in [ec_state_name_from_usps_abbrev $usps_abbrev]"
    }
    
    if {![regexp {^[0-9|.]+$}  $tax_rate(${usps_abbrev}) match ] } {
	incr exception_count
	append exception_text	"<li>Please enter a number for the tax rate of ${usps_abbrev} ."
	
    } 
    if {[regexp {^[.]$}  $tax_rate(${usps_abbrev}) match ]} {
	incr exception_count
	append exception_text "<li>Please enter a number for the tax rate of ${usps_abbrev} ."
    }


}

if { $exception_count > 0 } {
    ad_return_complaint $exception_count $exception_text
}

set old_states_with_taxes_set [db_list unused "select usps_abbrev from ec_sales_tax_by_state"]

db_transaction {

    foreach usps_abbrev $usps_abbrev_list {
	set ip_addr [ns_conn peeraddr]
	set ship_status $shipping_p($usps_abbrev)  
	set state_tax_rate [ec_percent_to_decimal $tax_rate($usps_abbrev)]
	
	if { [db_string states_with_tax_count {
	    select count(*) 
	    from ec_sales_tax_by_state 
	    where usps_abbrev=:usps_abbrev
	}] > 0 } {
	    db_dml sales_tax_update {
		update ec_sales_tax_by_state 
		set tax_rate=:state_tax_rate,
		shipping_p=:ship_status,
		last_modified=sysdate, 
		last_modifying_user=:user_id, 
		modified_ip_address=:ip_addr 
		where usps_abbrev=:usps_abbrev
	    }
	} else {
	    db_dml sales_tax_insert {
		insert into ec_sales_tax_by_state
		(usps_abbrev, tax_rate, shipping_p, last_modified, last_modifying_user, modified_ip_address)
		values
		(:usps_abbrev, :state_tax_rate, :ship_status, sysdate, :user_id, :ip_addr)
	    }
	}
    }
    
    # get rid of rows for states where tax is no longer being collected
    foreach old_state $old_states_with_taxes_set {
	if { [lsearch $usps_abbrev_list $old_state] == -1 } {
	    # then this state is no longer taxable
	    db_dml delete_state_tax  {
		delete from ec_sales_tax_by_state 
		where usps_abbrev=:old_state
	    }
	    ec_audit_delete_row [list $old_state] [list usps_abbrev] ec_sales_tax_by_state_audit
	}
    }
    
}

db_release_unused_handles

ad_returnredirect index.tcl

