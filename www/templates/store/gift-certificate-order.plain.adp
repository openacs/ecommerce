<ec_header>Gift Certificates</ec_header>
<ec_navbar></ec_navbar>

<h2>Gift Certificates</h2>

<blockquote>

The perfect gift for anyone, gift certificates
can be used to to buy anything at
<%= $system_name %>!

<p>

<a href=<%= "\"$order_url\"" %>>Order a Gift Certificate!</a>

<p>

<b>About Gift Certificates</b>

<ul>
<li>Gift certificates are sent to the recipient via email shortly after you place your order.
<li>Any unused balance will be put in the recipient's gift certificate account.
<li>Gift certificates expire <%= $expiration_time %> from date of purchase.
<li>You can purchase a gift certificate for any amount between
<%= $minimum_amount %> and <%= $maximum_amount %>.
</ul>

</blockquote>

<ec_footer></ec_footer>



