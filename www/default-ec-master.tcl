# Set basic attributes and provide the logical defaults for variables that
# aren't provided by the slave page.
#
# Author: Bart Teeuwisse <bart.teeuwisse@7-sisters.com>
# Creation Date: April 2002
#

# Pull out the package_id of the subsite closest to our current node

set pkg_id [site_node_closest_ancestor_package "acs-subsite"]

# See if we have the parameter in the closest acs-subsite package to
# override this file in favor of the site-specific master

set have_site_master_p [ad_parameter -package_id $pkg_id UseSiteSpecificMaster dummy "0"]
if {$have_site_master_p} {
    ad_return_template "/www/site-specific-master"
}

# fall back on defaults for title and header_stuff

if [template::util::is_nil title] { 
    set title [ad_parameter SystemName -default [ad_system_name]]
} else {
    set title "[ad_parameter SystemName -default [ad_system_name]] : $title"
}
if ![info exists header_stuff] { 
    set header_stuff {}
}
if [template::util::is_nil navbar] { 
    set navbar "none"
}
if [template::util::is_nil footer] { 
    set footer [ec_footer]
}

set top_links ""
if { [string compare $navbar "Shopping Cart"] == 0 } {
    lappend top_links "<b>Shopping Cart</b>"
} else {
    lappend top_links "<a href=\"[ec_insecurelink shopping-cart]\">Shopping Cart</a>"
}

if { [string compare $navbar "Your Account"] == 0 } {
    lappend top_links "<b>Your Account</b>"
} else {
    lappend top_links "<a href=\"[ec_insecurelink account]\">Your Account</a>"
}

if { [string compare $navbar "Home"] == 0 } {
    lappend top_links "<b>[ec_system_name] Home</b>"
} else {
    lappend top_links "<a href=\"[ec_insecurelink index]\">[ec_system_name] Home</a>"
}

if {[ad_permission_p [ad_conn package_id] admin]} {
    lappend top_links "<a href=\"admin/\">[ec_system_name] Administration</a>"
}

set top_links "
    <table width=100%>
      <tr>
        <td>[ec_header_image]</td>
        <td align=right>
    	  [join $top_links " | "]
    	</td>
      </tr>
    </table>"

# Attributes

# template::multirow create attribute key value
# template::multirow append \
#     attribute bgcolor [ad_parameter -package_id $pkg_id bgcolor   dummy "white"]
# template::multirow append \
#     attribute text    [ad_parameter -package_id $pkg_id textcolor dummy "black"]

if { [info exists prefer_text_only_p]
     && $prefer_text_only_p == "f"
     && [ad_graphics_site_available_p] } {
    template::multirow append attribute background \
	[ad_parameter -package_id $pkg_id background dummy "/graphics/bg.gif"]
}

# Developer-support

if { [llength [namespace eval :: info procs ds_link]] == 1 } {
     set ds_link "[ds_link]"
} else {
    set ds_link ""
}
