<ec_header>Your Account</ec_header>
<ec_navbar>Your Account</ec_navbar>

<blockquote>

<form method=post action="update-user-classes-2.tcl">

<%
# we will break out into a little Tcl so that you can change
# the message you give users depending on whether they need
# approval to become a member of a user class

if { $user_classes_need_approval } {
    set select_message "Submit a request to be in the following user classes:"
} else {
    set select_message "Select the user classes you belong in:"
}
%>

<%= $select_message %>

<blockquote>
<%= $user_class_select_list %>
</blockquote>

<center>
<input type=submit value=Done>
</center>
</form>


</blockquote>

<ec_footer></ec_footer>