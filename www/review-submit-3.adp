<master>
  <property name="title">Thank You For Your Review of @product_name@</property>
  <property name="context_bar">@context_bar@</property>
  <property name="signatory">@ec_system_owner@</property>

  <include src="toolbar">

<blockquote>
  <if @comments_need_approval@ true>
    <p>Your review has been received.  Thanks for sharing your
      thoughts with us! It can take a few days for your review to
      appear on our web site.  If your review has not appeared on our
      site and you would like to know why, please send an email to <a
      href="@ec_system_owner@">@ec_system_owner@</a>.</p>
  </if>
  <else>
    <p>Your review has been received. Thanks for sharing your
      thoughts with us! Your review is now viewable from the
      @product_name page@.</p>
  </else>
  <p><a href="@product_link@">Return to the item you just reviewed.</a></p>
</blockquote>
