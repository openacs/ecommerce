ad_page_contract {

    License information of the Authorize.net Gateway, an
    implementation of the Payment Service Contract.

    @author Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @creation-date May 2002

} {
} -properties {
    title:onevalue
    context_bar:onevalue
}

# Authenticate the user

set user_id [ad_maybe_redirect_for_registration]

set package_name "Ecommerce"
set title "$package_name License"

# Set the context bar.

set context_bar [ad_context_bar [list . $package_name] License]

# Set signatory for at the bottom of the page

set signatory "bart.teeuwisse@thecodemill.biz"
