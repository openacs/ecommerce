#     Add a [ Administer ] link at the far right to the context bar.

#     @param context_addition

#     @author Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
#     @cvs-id $Id$
#     @creation-date September 2002

# Create an empty context_addition list if no addition has been passed
# in.

if {![info exists context_addition]} {
    set context_addition {}
}

# Create a context bar with the passed in addition(s) if any.

if {[empty_string_p $context_addition]} {
    set context_bar [ad_context_bar]
} else {
    set context_bar [eval ad_context_bar $context_addition]
}

# Check for admin rights to this (the ecommerce) package.

set ec_admin_p [ad_permission_p [ad_conn package_id] admin]
set ec_admin_link admin/

# Get the name of the ecommerce package

set ec_system_name [ec_system_name]

