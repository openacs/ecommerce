<ec_header>Add yourself to the $mailing_list_name mailing list!</ec_header>
<ec_navbar></ec_navbar>

<h2>Add yourself to the <%= $mailing_list_name %> mailing list!</h2>

<blockquote>
We think that you are <%= $user_name %>.  If not, please <a href="<%= $register_link %>">log in</a>.  Otherwise,

<p>

<form method=post action="mailing-list-add-2">
<%= $hidden_form_variables %>

<center>
<input type=submit value="Continue">
</center>
</form>

</blockquote>
<ec_footer></ec_footer>
