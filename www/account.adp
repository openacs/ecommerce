<master>
  <property name="title">Your account</property>
  <property name="context_bar">@context_bar@</property>
  <property name="signatory">@ec_system_owner@</property>

  <include src="toolbar" current_location="your-account">

<blockquote>
  <ul>
    <li><a href="/pvt/home">Your workspace at <%= [ad_system_name] %></a></li>
    @gift_certificate_sentence_if_nonzero_balance@

    @user_classes@
  </ul>

  <h3>Your Order History</h3>

  <ul>
    @past_orders@
  </ul>

  @purchased_gift_certificates@

  @mailing_lists@

</blockquote>
