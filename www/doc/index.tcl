ad_page_contract {

    Index to documentation of the ecommerce package, a
    package to implement business-to-consumer web services.

    @author Bart Teeuwisse <bart.teeuwisse@7-sisters.com>
    @creation-date May 2002

} {
} -properties {
    title:onevalue
    context_bar:onevalue
}

# Authenticate the user

set user_id [ad_maybe_redirect_for_registration]

set package_name "Ecommerce"
set title "$package_name Documentation"

# Check for read privileges

set package_id [apm_package_id_from_key "ecommerce"]
set admin_p [ad_permission_p $package_id read]
set package_url [apm_package_url_from_key "ecommerce"]

# Set the context bar.

set context_bar [template::adp_parse [acs_root_dir]/packages/ecommerce/www/doc/contextbar [list context_addition [list $title]]]

# Set signatory for at the bottom of the page

set signatory "bart.teeuwisse@7-sisters.com"
