# /www/master-default.tcl
#
# Set basic attributes and provide the logical defaults for variables that
# aren't provided by the slave page.
#
# Author: Kevin Scaldeferri (kevin@arsdigita.com)
# Creation Date: 14 Sept 2000
# $Id$
#

# fall back on defaults

if { [template::util::is_nil title] } {
    set title [ad_conn instance_name]
}

# following added for site-wide ecommerce toolbar
# Is requested page not in ecommerce package?
if { [apm_package_installed_p ecommerce] } {
    set is_not_in_ecommerce_p [expr [ad_conn package_id] != [ec_id] ]
} else {
    set is_not_in_ecommerce_p 1
}

# Create empty values for each optional parameter that has not been passed from other template levels.
foreach parameter {combocategory_id category_id subcategory_id search_text current_location} {
    if {![info exists $parameter]} {
	set $parameter {}
    }
}

