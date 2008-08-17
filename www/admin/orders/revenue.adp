<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<table border=0 cellspacing=0 cellpadding=10>
<tr><td><b>Period</b></td><td colspan=2><b>Revenue</b> <sup>1</sup></td></tr>
@reportable_transactions_select_html;noquote@
<tr><td>&nbsp;</td><td></td><td></td></tr>
<tr><td><b>Period</b></td><td colspan=2><b>Product Sales</b> <sup>2</sup></td></tr>
@money_select_html;noquote@
<tr><td>&nbsp;</td><td></td><td></td></tr>

<tr><td><b>Period</b></td><td colspan=2><b>Gift Certificate Sales</b><sup>3</sup></td></tr>
@gift_certificates_sales_html;noquote@
<tr><td>&nbsp;</td><td></td><td></td></tr>

<tr><td><b>Period</b></td><td colspan=2><b>Gift Certificates Issued</b><sup>4</sup></td></tr>
@gift_certificates_issued_html;noquote@
<tr><td>&nbsp;</td><td></td><td></td></tr>
<tr><td><b>Expires</b></td><td colspan=2><b>Gift Certificates Outstanding</b> <sup>5</sup></td></tr>
@gift_certificates_approved_html;noquote@
</table>

<p>
<sup>1</sup> <b>Revenue</b>: the actual amount of credit card charges minus the amount of credit card refunds.
</p><p>
<sup>2</sup> <b>Sales</b>: the price charged, the shipping charged, and the tax charged (minus the amounts refunded) for shipped items (most companies recognize revenue when items are shipped so that they don't risk double counting an account receivable and an item in inventory; see the <a href="http://philip.greenspun.com/panda/ecommerce.html">ecommerce chapter of Philip &amp; Alex's Guide to Web Publishing</a>).  Note that this is different from revenue because revenue includes sales of gift certificates.  Additionally, some products were paid for using gift certificates.
</p><p>
<sup>3</sup> <b>Gift Certificate Sales</b>: the amount of gift certificates purchased (recognized on date of purchase).
</p><p>
<sup>4</sup> <b>Gift Certificates Issued</b>: the amount of gift certificates issued to customers free of charge by web site administrators.
</p><p>
<sup>5</sup> <b>Gift Certificates Outstanding</b>: gift certificates which have not yet been applied to shipped items (therefore they are considered a liability).
</p>
