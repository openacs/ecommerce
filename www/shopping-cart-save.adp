<master>
  <property name="title">Save Shopping Cart</property>
  <property name="context_bar">@context_bar@</property>
  <property name="signatory">@ec_system_owner@</property>

  <include src="toolbar" current_location="your-account">

<blockquote>
  <p>We think that you are @user_name@.  If not, please <a
  href="@register_link@">log in</a>. Otherwise,</p>
  <form method=post action="shopping-cart-save-2">
    <center>
      <input type=submit value="Continue">
    </center>
  </form>
</blockquote>
