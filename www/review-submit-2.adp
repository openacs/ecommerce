<master>
  <property name="title">Check Your Review of @product_name;noquote@</property>
  <property name="context_bar">@context_bar;noquote@</property>
  <property name="signatory">@ec_system_owner;noquote@</property>

  <property name="show_toolbar_p">t</property>

<blockquote>
  <form method="post" action="review-submit-3">
    @hidden_form_variables;noquote@
    <p>Here is your review the way it will appear:</p>
    <hr>
    <p>@review_introduction;noquote@ <b>@one_line_summary@</b> <br>@user_comment@</p>

    <hr>
    <p>If this isn't the way you want it to look, please back up using
    your browser and edit your review.  Submissions become the
    property of @system_name@.</p>
    <center>
      <input type="submit" value="Submit your review">
    </center>
  </form>
</blockquote>
