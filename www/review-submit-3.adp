<master src="default-ec-master">
<property name="title">Thank you for your review of @product_name@</property>

<h2>Thank you for your review of @product_name@</h2>

<blockquote>
  <if @comments_need_approval@ true>
    <p>Your review has been received.  Thanks for sharing your
      thoughts with us! It can take a few days for your review to
      appear on our web site.  If your review has not appeared on our
      site and you would like to know why, please send an email to <a
      href="@system_owner_email@">@system_owner_email@</a>.</p>
  </if>
  <else>
    <p>Your review has been received. Thanks for sharing your
      thoughts with us! Your review is now viewable from the
      @product_name page@.</p>
  </else>
  <p><a href="@product_link@">Return to the item you just reviewed.</a></p>
</blockquote>
