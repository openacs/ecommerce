<ec_header>Write your own review of $product_name</ec_header>
<ec_navbar></ec_navbar>

<h2>Write your own review of <%= $product_name %></h2>

<form method=post action="review-submit-2.tcl">

<input type=hidden name=product_id value=<%= "\"$product_id\"" %>>

<ol>
<li>What is your rating of this product? <%= $rating_widget %>

<p>

<li>Please enter a headline for your review:<br>
<input type=text size=50 name="one_line_summary">

<p>

<li>Enter your review below: (maximum of 1,000 words)<br>
<textarea wrap name="user_comment" rows=6 cols=50></textarea>

<p>

<li>We want to give you a chance to see how your review will appear before we place it online. Please take a minute to 
<input type=submit value="Preview your Review">
</form>

</ol>

<ec_footer></ec_footer>
