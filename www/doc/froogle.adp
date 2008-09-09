<!-- <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"> -->

<master>
  <property name=title>Froogle data feed</property>
  <property name="signatory">@signatory@</property>

  <h2>@title@</h2>
  <table width="100%">
    <tbody>
      <tr>
	<td align="left">@context_bar;noquote@</td>
      </tr>
    </tbody>
  </table>
  <hr />

  <h2>What's the benefit of being listed in Froogle?</h2>

  <p><a href="http://froogle.google.com/">Froogle</a> is an extension
  of the Google search engine that millions of people around the globe
  use daily to research products before they purchase. Listing your
  product in Froogle is a free way to extend the reach of your
  marketing efforts to millions of new customers.</p>

  <p>Google's worldwide user base performs more than 150 million
  searches a day. That presents an enormous opportunity to introduce
  your products to customers you might otherwise spend millions of
  dollars in advertising to reach. These are people actively searching
  for the items you sell. And did we mention inclusion in Froogle is
  absolutely free?</p>

  <h2>Why submitting a data feed?</h2>

  <p>Submitting a data feed will ensure that your entire product
  catalog is included in Froogle, and it will also allow you to
  control the freshness and accuracy of your product
  information. Feeds can be updated as you add new products, change
  prices, offer special promotions, or discontinue products.</p>

  <p>If you would like to submit a data feed of your store's product
  catalog to Froogle, you need open an account first, please complete
  and submit <a
  href="http://services.google.com/froogle/merchant_email">this
  form</a>.</p>

  <p>There are a few conditions
  and limitations you should know about if you are thinking of
  providing a feed to Froogle. (<a
  href="http://www.google.com/basepages/sellongoogle.html">read more
  about foogle</a>).</p>

  <h2>How to configure ecommerce to provide a data feed</h2>

  <p>After obtaining a Froogle account fill out the parameters in the
  Froogle section of the ecommerce package. Then schedule the <code><a
  href="/api-doc/proc/froogle::upload">froogle::upload</a></code>
  procedure to be run at an interval of your choice. Done!</p>

  <h2>Which information will be uploaded to Froogle?</h2>

  <p>Only information of active products is uploaded to a Froogle Ftp
  server. The product description submitted to Froogle is composed of
  the one line description and the detailed description both stripped
  from tabs, carriage-returns and newlines as well as HTML tags to
  conform to Froogle's strict <a
  href="froogle_feed_instructions.pdf">data format</a>.</p>

  <h2>What could be improved?</h2>

  <p>Products are assumed to be belong to only one
  category. Subcategories and sub-sub-categories are ignored as the
  site this procedure was written for doesn't use them.</p>

  <h2>Any technical requirements?</h2>

  <p>Like OpenACS 5.3+, Froogle::upload relies on the ftp package in <a
  href="http://tcllib.sourceforge.net/">tcllib</a> to perform the
  actual Ftp upload. As such tcllib has to be installed and ecommerce
  should be running on AOLserver.</p>
