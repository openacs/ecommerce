<ec_header>Retrieve Shopping Cart</ec_header>
<ec_header_image></ec_header_image><br clear=all>

<h2>Retrieve Your Shopping Cart</h2>

<blockquote>

We think that you are <%= $user_name %>.  If not, please 
<a href="<%= $register_link %>">log in</a>.

Otherwise,

<p>

<form method=post action="shopping-cart-retrieve-2.tcl">
<center>
<input type=submit value="Continue">
</center>
</form>

</blockquote>
<ec_footer></ec_footer>