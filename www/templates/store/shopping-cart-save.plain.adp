<ec_header>Save Shopping Cart</ec_header>
<ec_navbar></ec_navbar>

<h2>Save Your Shopping Cart</h2>

<blockquote>

We think that you are <%= $user_name %>.  If not, please <a href="<%= $register_link %>">log in</a>. Otherwise,

<p>

<form method=post action="shopping-cart-save-2.tcl">
<center>
<input type=submit value="Continue">
</center>
</form>

</blockquote>
<ec_footer></ec_footer>
