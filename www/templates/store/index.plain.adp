<ec_header>Welcome to [ec_system_name]</ec_header>

<ec_navbar>Home</ec_navbar>

<blockquote>
<br>

<%
# Here's a little Tcl "if statement" so that we can give them
# a different welcome message depending on whether they're
# logged on.  If you edit the text, please remember to put
# a backslash before any embedded quotation marks (\") you add.

if { $user_is_logged_on } {
    set welcome_message "Welcome back $user_name!&nbsp;&nbsp;&nbsp;If you're not $user_name, click <a href=\"$register_url\">here</a>."
} else {
    set welcome_message "Welcome!"
}

# and another statement which depends on whether gift certificates
# can be bought on this site (remember to put a backslash before any
# embedded quotation marks (\") you add.)

if { $gift_certificates_are_allowed } {
    set gift_certificate_message "<a href=\"gift-certificate-order\">Order a Gift Certificate!</a>"
} else {
    set gift_certificate_message ""
}

# We're done with the Tcl.
%>

<%= $welcome_message %>


<%= $search_widget %>

<p>

<%= $recommendations_if_there_are_any %>

<%= $products %>

<%= $prev_link %> <%= $separator %> <%= $next_link %>


<p align=right>
<%= $gift_certificate_message %>
</p>

</blockquote>

<ec_footer>Home</ec_footer>

