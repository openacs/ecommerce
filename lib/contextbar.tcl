#     Add a [ Administer ] link to the template
# Check for admin rights to this (the ecommerce) package.

set ec_admin_p [permission::permission_p -no_login -object_id [ad_conn package_id] -privilege admin]
if {$ec_admin_p} {
    set ec_admin_link "[ec_url]admin/"
}

# Get the name of the ecommerce package

set ec_system_name [ec_system_name]

