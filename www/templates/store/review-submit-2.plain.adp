<ec_header>Check Your Review</ec_header>
<ec_navbar></ec_navbar>

<!-- <ec_header_image></ec_header_image><br clear=all> -->

<h2>Check your review of <%= $product_name %></h2>

<blockquote>

<form method=post action=review-submit-3.tcl>
<%= $hidden_form_variables %>

Press this button when you are ready to <input type=submit value="submit your review">

<p>

Here is your review the way it will appear:

<hr>

<%= $review_as_it_will_appear %>
<p>

<hr>

If this isn't the way you want it to look, please back up using your browser and edit your review.  Submissions become the property of <%= $system_name %>.

<p>

Press this button when you are ready to <input type=submit value="submit your review">
</form>

</blockquote>

<ec_footer></ec_footer>