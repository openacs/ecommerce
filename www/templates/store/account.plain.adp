<ec_header>Your Account</ec_header>
<ec_navbar>Your Account</ec_navbar>

<blockquote>
<ul>
<li><a href="/pvt/home">Your workspace at <%= [ad_system_name] %></a>
<%= $gift_certificate_sentence_if_nonzero_balance %>

<%= $user_classes %>
</ul>

<p>
<h3>Your Order History</h3>

<ul>
<%= $past_orders %>
</ul>

<%= $purchased_gift_certificates %>

<%= $mailing_lists %>

</blockquote>

<ec_footer>Your Account</ec_footer>
