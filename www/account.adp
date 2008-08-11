<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
  <property name="signatory">@ec_system_owner;noquote@</property>

  <property name="current_location">your-account</property>

<include src="/packages/ecommerce/lib/toolbar">
<include src="/packages/ecommerce/lib/searchbar">

<blockquote>
  <ul>
    <li><a href="/pvt/home">Your workspace at <%= [ad_system_name] %></a></li>
    @gift_certificate_sentence_if_nonzero_balance;noquote@

    @user_classes;noquote@
  </ul>

  <h3>Your Order History</h3>

  <ul>
    @past_orders;noquote@
  </ul>

  @purchased_gift_certificates;noquote@

  @mailing_lists;noquote@

</blockquote>
