<master src="default-ec-master">
<property name="title">Check Your Review</property>

<h2>Check your review of @product_name@</h2>

<blockquote>
  <form method="post" action="review-submit-3">
    @hidden_form_variables@
    <p>Here is your review the way it will appear:</p>
    <hr>
    <p>@review_as_it_will_appear@</p>
    <hr>
    <p>If this isn't the way you want it to look, please back up using
    your browser and edit your review.  Submissions become the
    property of @system_name@.</p>
    <center>
      <input type="submit" value="Submit your review">
    </center>
  </form>
</blockquote>
