# /tcl/ecommerce-ssl-procs.tcl
ad_library {
    Definitions for the ecommerce module
    Note: Other ecommerce procedures can be found in ecommerce-*.tcl

    @cvs-id $Id$
    @author jerry asher (jerry-ecommerce@hollyjerry.org)
    @author Walter McGinnis (wtem@olywa.net)
    @creation-date Jan, 2001
}

##############################
##############################

ad_proc ec_preferred_drivers {} {
    Determine if we implement nssock or nsunix. Favor nsunix if possible.
    Determine if we implement nsopenssl or nsssl.  Favor nsssl.

    Easiest way to call is with returned array indices.

    array set drivers [ec_preferred_drivers]

} {
    
    set driver ""
    set sdriver ""

    if {[ns_conn isconnected]} {
        set hdrs [ns_conn headers]
        set host [ns_set iget $hdrs host]
        if {[string equal "" $host]} {
            set driver nssock
        } 
    }

    ###   Determine nssock or nsunix

    if {[string equal "" $driver]} {

        # decide if we're using nssock or nsunix
        set nssock [ns_config ns/server/[ns_info server]/modules nssock]
        set nsunix [ns_config ns/server/[ns_info server]/modules nsunix]

        if {![empty_string_p $nssock] && ![empty_string_p $nsunix]} {
            set driver [ad_parameter -package_id [ec_id] httpModule ecommerce nsunix]
        } elseif {[empty_string_p $nssock]} {
            set driver nsunix
        } else {
            set driver nssock
        }
    }

    ###    ###    ###    ###    ###    ###    ###    ###    ###    ###    ###
    ###   Determine nsssl or nsopenssl (favor nsopenssl)
    ###    ###    ###    ###    ###    ###    ###    ###    ###    ###    ###

    # decide if we're using nsssl or nsopenssl 
    set nsssl [ns_config ns/server/[ns_info server]/modules nsssl]
    set nsopenssl [ns_config ns/server/[ns_info server]/modules nsopenssl]

    if {![empty_string_p $nsssl] && ![empty_string_p $nsopenssl]} {
        set sdriver [ad_parameter -package_id [ec_id] httpsModule ecommerce nsopenssl]
    } elseif {[empty_string_p $nsssl]} {
        set sdriver nsopenssl
    } else {
        set sdriver nsssl
    }

    return [list driver $driver sdriver $sdriver]
}

ad_proc ec_secure_location {} {
    @returns the secure location https://host:port, favoring the https module specified as an ecommerce parameter.
} {

    set loc [ad_parameter -package_id [ec_id] SecureLocation]
    if {[empty_string_p $loc] || [string equal -nocase $loc "No Value"]} {

        set sdriver [ad_parameter -package_id [ec_id] httpsModule]
        if {[empty_string_p $sdriver]} {
            array set drivers [ec_preferred_drivers]
            set sdriver $drivers(sdriver)
        }
            
        set secure_port [ns_config -int "ns/server/[ns_info server]/module/$sdriver" Port]
	### nsopenssl 2.0 has different names for the secure port
	if { [empty_string_p $secure_port] } {
	    set secure_port [ns_config -int "ns/server/[ns_info server]/module/$sdriver" ServerPort 443]
	}
        ### nsopenssl 3 has variable locations for the secure port
        # this is matched to the aolserver config.tcl
        if { [empty_string_p $secure_port] || [string match $secure_port 443] } {
	    set secure_port [ns_config -int "ns/server/[ns_info server]/module/$sdriver/ssldriver/users" port 443]
	}

        set secure_location "https://[ns_config ns/server/[ns_info server]/module/$sdriver Hostname]"
	### nsopenssl 2.0 uses ServerHostname instead of Hostname
        if { [string match $secure_location "https://"] } {
	    set secure_location "https://[ns_config ns/server/[ns_info server]/module/$sdriver ServerHostname]"
	}
        ### nsopenssl 3 uses Hostname and custom driver name
        # made need to make users/inboundssl (custom driver name) another parameter value
        if { [string match $secure_location "https://"] } {
	    set secure_location "https://[ns_config ns/server/[ns_info server]/module/$sdriver/ssldriver/users hostname]"
	}

        if {![empty_string_p $secure_port] && ($secure_port != 443)}  {
            append secure_location ":$secure_port"
        }

        return  $secure_location
    } else {
        return $loc
    }
}

ad_proc ec_insecure_location {} {
    @return the insecure location, favoring the InsecureLocation ecommerce parameter.
} {
    set loc [ad_parameter -package_id [ec_id] InsecureLocation]
    if {[empty_string_p $loc] || [string equal -nocase $loc "No Value"]} {
        # set sdriver [ad_parameter -package_id [ec_id] httpsModule]
        set driver [ad_parameter -package_id [ec_id] httpModule]
        if {[empty_string_p $driver] || [string equal -nocase $loc "No Value"]} {
            array set drivers [ec_preferred_drivers]
            set driver $drivers(driver)
        }
            
        set insecure_port [ns_config -int "ns/server/[ns_info server]/module/$driver" Port 80]
        set insecure_location "http://[ns_config ns/server/[ns_info server]/module/$driver Hostname]"
        if {![empty_string_p $insecure_port] && ($insecure_port != 80)}  {
            append insecure_location ":$insecure_port"
        }

        return  $insecure_location
    } else {
        return $loc
    }
}

ad_proc ec_ssl_available_p {} {
    Returns 1 if this AOLserver has either the nsssl module or nsopenssl module installed.
} {
    if { [ns_config ns/server/[ns_info server]/modules nsssl] != "" } {
	return 1
    } elseif { [ns_config ns/server/[ns_info server]/modules nsopenssl] != "" } {
	return 1
    } else {
	return 0
    }
}

ad_proc ec_redirect_to_https_if_possible_and_necessary {} {
    redirects the current url to the appropriate https address
} {
    uplevel {
	# wtem@olywa.net, 2001-03-22
	# made this simpler by relying on ad_secure_conn_p
	if {![ad_secure_conn_p]} {
	    # see if ssl is installed
	    # replaced ad_ssl_available_p with ec_ssl_available_p
	    # which detects nsopenssl
	    if { ![ec_ssl_available_p] } {
		# there's no ssl
		# if ssl is required return an error message; otherwise, do nothing
		ad_return_error "No SSL available" "
		    We're sorry, but we cannot display this page because SSL isn't available from this site.  Please contact <a href=\"mailto:[ad_system_owner]\">[ad_system_owner]</a> for assistance.
		    "
	    } else {
		# figure out where we should redirect the user
		set secure_url "[ec_secure_location][ns_conn url]"
		set vars_to_export [ec_export_entire_form_as_url_vars_maybe]
		if { ![empty_string_p $vars_to_export] } {
		    set secure_url "$secure_url?$vars_to_export"
		}

		# if the user is switching to a secure connection
		# they should re-login

		# grab the user_id 
		# 0 if user is not logged in
		set user_id [ad_verify_and_get_user_id]

		# grab the current user_session_id
		# otherwise we lose the session 
		# when we set new cookies for https
		# there is corresponding setting of user_session_id cookie
		# in packages/ecommerce/www/register/user-login.tcl
		set user_session_id [ec_get_user_session_id]

		# we need the specialized ecommerce register pipeline
		# based out of the ecommerce instance site-node
		# so that links from both /ecommerce-instance/ and 
		# and /ecommerce-instance/admin work

		set register_url "[ec_securelink [ad_get_login_url]]?return_url=[ns_urlencode $secure_url]&http_id=$user_id&user_session_id=$user_session_id"
		ad_returnredirect $register_url
		template::adp_abort
	    }
	}
    }
}

######################################################################
### helper routines to transition to and from the SSL protocol and socket
######################################################################
ad_proc ec_makesecure {} {

    If the current page isn't secure, will ad_returnredirect the user to the
    https version of the page. If neither nsssl or nsopenssl is installed,
    the function will return 0 but not try to redirect. Uses the
    nsssl and nsopensssl/Port entry in the config.tcl file to guess the secure port (or
    will leave it off if the port isn't specified (in which case we're
    using the default https port)).

} {

    if { [string match "nsssl" [ns_conn driver]] ||
    [string match "nsopenssl" [ns_conn driver]] } {
        # we don't need to do anything
        return 1
    } else {
        if {([empty_string_p [ns_config ns/server/[ns_info server]/modules nsssl]]) && 
            ([empty_string_p [ns_config ns/server/[ns_info server]/modules nsopenssl]])} {
            # we don't have ssl installed. Give up.
            return 0
        } else {
            array set drivers [ec_preferred_drivers]
            set secure_url "https://[ns_info hostname]"
            set secure_port [ns_config ns/server/[ns_info server]/module/$drivers(sdriver) ServerPort]
            if ![empty_string_p $secure_port] {
                append secure_url ":$secure_port"
            }
            append secure_url [ns_conn url]
            set query_string [ns_conn query]
            if ![empty_string_p $query_string] {
                append secure_url "?$query_string"
            }
            ad_returnredirect $secure_url
            # return -code return
            ad_script_abort
        }
    }
}

ad_proc ec_makeinsecure {} {

    If the current url is secure, will redirect the user to the
    insecure version of this page. One disadvantage of this
    is the Netscape throws up a "the  document you requested was 
    supposed to be secure" window. ec_insecurelink might be a 
    better choice.

} {

    if ![string match "nsssl" [ns_conn driver]] &&
    ![string match "nsopenssl" [ns_conn driver]] {
        return
    } else {
        # decide if we're using nssock or nsunix
        array set drivers [ec_preferred_drivers]

        set loc [ns_config ns/server/[ns_info server]/module/$drivers(driver) location]
        set url $loc
        append url [ns_conn url]
        set query_string [ns_conn query]
        if ![empty_string_p $query_string] {
            append url "?$query_string"
        }
        ad_returnredirect $url
        ad_script_abort
    }
}

ad_proc ec_securelink {new_page} {

    Creates a url to a secure page from a relative url that may or may not be secure

} {

    if {![ec_ssl_available_p]} {
        # we don't have ssl installed, so return the original URL
        return $new_page
    }

    if { [string match "nsssl" [ns_conn driver]] || [string match "nsopenssl" [ns_conn driver]] } {
        # we are already connected via ssl, no need to do anything
        return $new_page
    } else {

        set new_url [ec_secure_location]
        
        if [string match /* $new_page] {
            append new_url $new_page
        } else {
            set current_url [ns_conn url]
            regexp {^(.*)/} $current_url match new_url_dir
            append new_url "$new_url_dir/$new_page"
        }
        return $new_url
    }
}

ad_proc ec_insecurelink {new_page} {

    Creates a url from a possible secure page to an insecure page

} {
    if {![ec_ssl_available_p]} {
        # we don't have ssl installed, so return the original URL
        return $new_page
    }

    if {(![string match "nsssl" [ns_conn driver]] && ![string match "nsopenssl" [ns_conn driver]])} {
        # We're not on a secure page, so this relative link is already
        # doing the right thing.
        return $new_page
    } else {

        array set drivers [ec_preferred_drivers]

        set new_url "[ns_config ns/server/[ns_info server]/module/$drivers(driver) location]"
        set new_url [string trimright $new_url /]
#          set port [ns_config ns/server/[ns_info server]/module/$driver Port]
#          if {![empty_string_p $port] && ($port != 80)} {
#             append new_url ":$port"
#          }

        if [string match /* $new_page] {
           append new_url $new_page
        } else {
           set current_url [ns_conn url]
           regexp {^(.*)/} $current_url match new_url_dir
           append new_url "$new_url_dir/$new_page"
        }
        set new_url "[ad_url]$new_url"
        return $new_url
    }
}

ad_proc ec_insecure_context_bar_ws_and_index args {

    Returns a Yahoo-style hierarchical navbar, starting with a link to
    / and possibly the workspace or /, depending on whether or not the
    user is logged in.

} {
    set choices [list "<a href=\"[ec_insecurelink /]\">[ec_system_name]</a>"] 
    if { ![ad_get_user_id] == 0 } {
	lappend choices "<a href=\"[ec_insecurelink [ad_pvt_home]]\">Your Workspace</a>"
    }
    set index 0
    foreach arg $args {
	incr index
	if { $index == [llength $args] } {
	    lappend choices $arg
	} else {
	    lappend choices "<a href=\"[ec_insecurelink [lindex $arg 0]]\">[lindex $arg 1]</a>"
	}
    }
    return [join $choices " : "]
}
