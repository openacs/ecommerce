<ec_header>Thank you for your review of $product_name</ec_header>
<ec_navbar></ec_navbar>
<h2>Thank you for your review of <%= $product_name %></h2>

<blockquote>

<% 

# This is a Tcl "if statement" which used to give a different message to the
# users depending on whether your system was set up to automatically post user
# comments or to require administrator approval before comments are posted.
# If you edit any of the text, please remember to put a backslash before any
# nested quotation marks you add.

if { $comments_need_approval } {
	set message_to_print "Your review has been received.  Thanks for sharing
	your thoughts with us! It can take a few days for your review to appear
	on our web site.  If your review has not appeared on our site and you
	would like to know why, please send email to 
	<a href=\"$system_owner_email\">$system_owner_email</a>."
   } else {
	set message_to_print "Your review has been received.  Thanks for sharing
	your thoughts with us! Your review is now viewable from the $product_name page."
}

# OK, we're done with the "if statement"
%>

<%= $message_to_print %>

<p>

<a href=<%= "\"$product_link\"" %>>Return to the item you just reviewed.</a>

</blockquote>

<ec_footer></ec_footer>