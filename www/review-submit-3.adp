<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
  <property name="signatory">@ec_system_owner;noquote@</property>

<include src="/packages/ecommerce/lib/toolbar">
<include src="/packages/ecommerce/lib/searchbar">

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
