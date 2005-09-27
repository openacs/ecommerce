ad_page_contract {

    Accepts an email from the user and attempts to log the user in.

    @author Multiple
    @cvs-id $Id$
} {
    email:notnull
    {return_url [ad_pvt_home]}
    password:notnull
    {persistent_cookie_p 0}
    token_id
    time
    hash
    {user_session_id 0}
}

# there may be an old user_session_id cookie lying around
# we recreate a valid cookie at the end
# ec_user_session_logout

# Security check to prevent the back button exploit.

set token [sec_get_token $token_id]
set computed_hash [ns_sha1 "$time$token_id$token"]

if { [string compare $hash $computed_hash] != 0 } {
    # although this technically is not an expired login, we'll
    # just use it anyway.
    ad_returnredirect "login-expired"
    ad_script_abort
} elseif { $time < [ns_time] - [ad_parameter -package_id [ad_acs_kernel_id] LoginExpirationTime security 600] } {
    ad_returnredirect "login-expired"
    ad_script_abort
}

# Obtain the user ID corresponding to the provided email address.

set email [string tolower $email]

if { ![db_0or1row user_login_user_id_from_email {
    select user_id, member_state, email_verified_p
    from cc_users
    where email = :email}] } {

    # The user is not in the database. Redirect to user-new.tcl so the user can register.
    ad_set_client_property -persistent "f" register password $password
    ad_returnredirect "user-new?[ad_export_vars { email return_url persistent_cookie_p }]"

    ad_script_abort
}


db_release_unused_handles

switch $member_state {
    "approved" {
	if { $email_verified_p == "f" } {
	    ad_returnredirect "awaiting-email-verification?user_id=$user_id"
            ad_script_abort
	}
	if { [ad_check_password $user_id $password] } {
	    # The user has provided a correct, non-empty password. Log
	    # him/her in and redirect to return_url.
	    ad_user_login -forever=$persistent_cookie_p $user_id
	    # this one way the ecommerce version of register pipeline
	    # differs from the acs version
	    # kludge follows:
	    # we expire user_session_id when user visits register pipeline
	    # so that new users loggin in don't inherit old user_session_id
	    # but sometimes we arrive for a re-login for a secure transaction
	    # in this case we pass in the user_session_id as form_var
	    # and re-instate the user_session_id cookie at the end
	    # since the user_session_id is in the url_vars
	    # a better solution would be to check 
	    if {$user_session_id > 0} {
		# reinstate the cookie
		ad_set_cookie -replace "t" -path "/" user_session_id $user_session_id
	    } else {
		# this is a new user and thus a new user_session_id is needed
		ec_create_new_session_if_necessary
	    }
	    ad_returnredirect $return_url
	    ad_script_abort
	}
    }
    "banned" { 
	ad_returnredirect "banned-user?user_id=$user_id" 
	ad_script_abort
    }
    "deleted" {  
	ad_returnredirect "deleted-user?user_id=$user_id" 
	ad_script_abort
    }
    "rejected" {
	ad_returnredirect "awaiting-approval?user_id=$user_id"
	ad_script_abort
    }
    "" {
	ad_returnredirect "awaiting-approval?user_id=$user_id"
	ad_script_abort
    }
    default {
	ns_log Warning "Problem with registration state machine on user-login.tcl"
	ad_return_error "Problem with login" "There was a problem authenticating the account: $user_id. Most likely, the database contains users with no user_state."
	ad_script_abort
    }
}

# The user is in the database, but has provided an incorrect password.
ad_returnredirect "bad-password?user_id=$user_id"
