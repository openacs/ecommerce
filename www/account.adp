<master>
  <property name="title">Your account</property>
  <property name="context_bar">@context_bar;noquote@</property>
  <property name="signatory">@ec_system_owner;noquote@</property>

  <property name="show_toolbar_p">t</property>
  <property name="current_location">your-account</property>

<blockquote>
  <ul>
    <li><a href="/pvt/home">Your workspace at <%= [ad_system_name] %></a></li>
    @gift_certificate_sentence_if_nonzero_balance;noquote@

    @user_classes;noquote@
  </ul>

  <h3>Your Order History</h3>

  <ul>
    @past_orders@
  </ul>

  @purchased_gift_certificates;noquote@

  @mailing_lists;noquote@

</blockquote>
