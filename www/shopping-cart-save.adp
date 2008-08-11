<master>
  <property name="doc(title)">@title@</property>
  <property name="context">@context;noquote@</property>
  <property name="signatory">@ec_system_owner;noquote@</property>

  <property name="current_location">your-account</property>

<include src="/packages/ecommerce/lib/toolbar">
<include src="/packages/ecommerce/lib/searchbar">

<blockquote>
  <p>We think that you are @user_name@.  If not, please <a
  href="@register_link@">log in</a>. Otherwise,</p>
  <form method=post action="shopping-cart-save-2">
    <center>
      <input type=submit value="Continue">
    </center>
  </form>
</blockquote>
