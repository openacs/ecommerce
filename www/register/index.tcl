ad_page_contract {
    Prompt the user for email and password.
    @cvs-id $Id$
} {
    { email "" }
    return_url:optional
    http_id:optional
    { user_session_id 0 }
} -properties {
    system_name:onevalue
    system_link:onevalue
    export_vars:onevalue
    email:onevalue
    old_login_process:onevalue
    allow_persistent_login_p:onevalue
    persistent_login_p:onevalue
}

set old_login_process [ad_parameter "SeparateEmailPasswordPagesP" security "0"]
set allow_persistent_login_p [ad_parameter AllowPersistentLoginP security 1]
set persistent_login_p [ad_parameter AllowPersistentLoginP security 1]

if {![info exists return_url]} {
    set return_url [ad_pvt_home]
}

set system_name [ad_system_name]
set system_link [ec_insecure_location]

# One common problem with login is that people can hit the back button
# after a user logs out and relogin by using the cached password in
# the browser. We generate a unique hashed timestamp so that users
# cannot use the back button.

set time [ns_time]
set token_id [sec_get_random_cached_token_id]
set token [sec_get_token $token_id]
set hash [ns_sha1 "$time$token_id$token"]

# http to https re-login handling
# use the value of http_id to determine the user's email address to display in the login form 
# *the following is done in the template
# if http_id is set, change the first headline of the page to "Secure Login" 
# if http_id is set, display a small banner, asking the user to "Please login to the secure server" 

# gilbertw: OpenACS templating fix
if {[info exists http_id]} {
    template::query get_email email onevalue "select email from parties where party_id = :http_id" 
} else {
    set http_id ""
}

# user_session_id added for ecommerce
set export_vars [export_form_vars return_url time token_id hash user_session_id]

ad_return_template
