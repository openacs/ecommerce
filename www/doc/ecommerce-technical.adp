<master>
  <property name=title>@title@</property>
  <property name="signatory">@signatory@</property>
  <property name="context_bar">@context_bar@</property>

  <h2>Setup</h2>

  <ul>

    <li>
      <p>Install an implementation of the <if
	@payment_gateway_installed@><a
	href="/dov/payment-gateway/"></if>Payment Service Contract<if
	@payment_gateway_installed@></a></if> such as the <if
	@authorize_gateway_installed@><a
	href="/doc/authorize-gateway/"></if>Authorize.net Gateway<if
	@authorize_gateway_installed@></a></if> or the VeriSign <if
	@payflowpro_gateway_installed@><a
	href="/doc/payflowpro/"></if>PayflowPro Gateway <if
	@payflowpro_gateway_installed@></a></if>.</p>

      <p>(Note: it can take a few weeks for your bank and a payment
	gateway to get your account ready, so get started on that
	right away!)</p>
    </li>

  <blockquote>
    
    <p>You can start testing @package_name@ with a <a
      href="https://www.verisign.com/cgi-bin/go.cgi?a=w181333180622000">VeriSign
      test account</a> and the <if @payflowpro_gateway_installed@><a
      href="/doc/payflowpro/"></if>PayflowPro Gateway <if
      @payflowpro_gateway_installed@></a></if>. With the 30-day FREE
      TRIAL, you'll see just how easy it is to begin accepting on-line
      payments.</p>

  </blockquote>

  <li>
    
    <p>These are the files in this @package_name@ release that you need to
      have to run the package:</p>

    
    <table>
      <tbody>
	<tr>
	  <th align="left">data model</th>
	  <td>in packages/ecommerce/sql/ecommerce*.sql</td>
	</tr>
	<tr>
	  <th align="left">documentation</th>
	  <td>in packages/ecommerce/www/doc/*</td>
	</tr>
	<tr>
	  <th align="left">scripts</th>
	  <td>in packages/ecommerce/www</td>
	</tr>
	<tr>
	  <th align="left">admin scripts</th>
	  <td>in packages/ecommerce/www/admin/</td>
	</tr>
	<tr>
	  <th align="left">tcl procs</th>
	  <td>in packages/ecommerce/tcl</td>
	</tr>
	<tr>
	  <th align="left">ecommerce parameters</th> 
	  <td>that can be reached from <a
	    href="/admin/site-map/">/admin/site-map/</a> (after
	    mounting an instance of @package_name@).</td>
	</tr>
      </tbody>    
    </table>
  </li>

  <li>
    <p>Install the <a href="http://www.openacs.org/">@package_name@</a>
      package.</p>
  </li>
  
  <li>

    <p><a href="http://www.imagemagick.org/">ImageMagick</a> (which is
      free) must be installed (either in /usr/local/bin/ or elsewhere
      if you're <a
      href="http://www.arsdigita.com/doc/security">running your server
      chrooted</a>) if you want thumbnails to be automatically
      created.  For information on the use of ImageMagick in OpenACS,
      see <a
      href="http://www.arsdigita.com/books/panda/images">Chapter 6:
      Adding Images to Your Site</a> of Philip and Alex's Guide to Web
      Publishing.</p>

  <li>

    <p>Install <a href="http://www.openssl.org">OpenSSL</a> and the <a
     href="http://www.scottg.net/webtools/aolserver/modules/nsopenssl/">nsopenssl</a>
     module for <a href="http://opennsd.org">OpenNSD</a> or <a
     href="http://aolserver.com">AOLServer</a> so that @package_name@
     can support secure transactions.</p>

    <p>Follow the nsopenssl installation <a
     href="http://www.scottg.net/webtools/aolserver/modules/nsopenssl/installation/">instructions</a>
     till the very end. @package_name@ uses ns_httpsopen, ns_httpsget
     or ns_httpspost calls and requires https.tcl to be installed.</p>

  <li>

    <p>Create an instance of @package_name@ using the <a
      href="/admin/site-map/">/admin/site-map/</a> on your server.</p>

    <ul>
      <li>
	<p>Create a new subfolder where you want to mount it.</p>
      </li>
      <li>
	<p>Create a new @package_name@ application for that mount point.</p>
      </li>
      <li>
	<p>Set parameters for the instance (see below).</p>
      </li>
    </ul>

  <li>
    <p>A /web/<i>yourserver</i>/data/ecommerce/product directory is
      needed to hold the products' supporting files (it's outside the
      web root so that no uploaded supporting files can be executed).
      The directory has to be write-able by nsadmin.  (You can change
      the directory by editing EcommerceDataDirectory and
      ProductDataDirectory in your @package_name@ parameters.)</p>
  </li>

  <li>
    <p>Based on the site owner's publishing decisions, @package_name@
      parameters need to be edited via /admin/site-map/.  Make sure to
      do the following:</p>
    
    <ul>
      <li>
	<p>Enable @package_name@, EnabledP should equal 1 in the
	  ecommerce section.</p>
      </li>
      <li>
	<p>Complete the SSL section fully.</p>
      </li>
      <li>
	<p>Pay particular attention to the technical, payment and
	  shipping sections:</p>
	<ul>
	  <li>
	    <p>CustomerServiceEmailAddress should be set to some real
	      email address</p>
	  </li>
	  <li>
	    <p>Make sure to replace <i>yourservername</i> in
	      EcommerceDataDirectory with the correct path!  This
	      parameter should also have a trailing slash!</p>
	  </li>
	  <li>
	    <p>ProductDataDirectory should have a trailing slash.</p>
	  </li>
	  <li>
	    <p>ImageMagickPath could vary on your machine, hunt down
	      the <i>convert</i> command on your system and update
	      this path.</p>
	  </li>
	  <li>
	    <p>Set PaymentGateway to the package key of the <if
              @payment_gateway_installed@><a
              href="/dov/payment-gateway/"></if>Payment Service
              Contract<if @payment_gateway_installed@></a></if>
              implementation you like to use to handle the financial
              transactions.</p>
	  </li>
	  <li>
	    <p>Set ShippingGateway to the package key of the <if
	      @shipping_gateway_installed@><a
	      href="/doc/shipping-gateway/"></if>Shipping Service
	      Contract<if @shipping_gateway_installed@></a></if>
	      implementation if you like to use different shipping
	      rules than the standard @package_name@ shipping
	      rules.</p>
	  </li>
	</ul>
    </ul>	
	
  <li>
    <p>Qmail must be installed on your system (it may require special
      setup if you're <a
      href="http://www.arsdigita.com/doc/security">running your server
      chrooted</a>).</p>
  </li>

  <li>
    <p>Optional: @package_name@ includes a customized version of the
      registration/login/logout pipeline which handles the transition
      to secure logins a bit more gracefully than the ACS Subsites
      Package.  You may want to patch the ACS Subsites and ACS TCL
      packages to match the behavior of @package_name@. See the <a
      href="kernel-patches">directions for applying the patch</a>.</p>

  <li>
    <p>Optional: If you want to have products be "visible" to the Site
      Wide Search package then you need to install the <a
      href="http://arsdigita.com/acs-repository/">Site Wide Search
      Package</a>, including all of its requirements for installation.
      During the installation of SWS or after run
      packages/ecommerce/sql/ec-products-sws-setup.sql to add products
      to your interMedia index.</p>

    <p><font color=red>Note: At this time (Version 4.0a, April 6th,
      2001) the interface to SWS has a bug (quite possibly the bug is
      actually in SWS) that prevents it from working.  See the <a
      href="release">Release Notes</a> for a bit more detail.  If you
      come up with a fix, send a patch to <a
      href="mailto:wtem@olywa.net">wtem@olywa.net</a>.</font></p>
  </li>
</ul>

  <h2>Under the Hood</h2>

  <p>This is provided just for your own information.  You may never
    need to know any of it, but it may prove useful if something goes
    wrong or if you want to extend the module.</p>

  <h3>Financial Transactions</h3>

  <blockquote>

    <p>A financial transaction is inserted whenever a credit card
      authorization to charge or refund is made.  These transactions
      may or may not be carried through to fulfillment.  The
      specifics:</p>

    <p>When an order is placed, an authorization is done for the full
      cost of the order. @package_name@ creates one or two new
      <code>ec_financial_transactions</code>.  Two rows are created
      when the order consists of some items that require shipping
      while others don't, otherwise @package_name@ creates a single
      row. The rows each have a unique <code>transaction_id</code> and
      are tied to the order using the
      <code>order_id</code>. @package_name@ immediately captures the
      transaction for the items that do not require
      shipping. @package_name@ doesn't captures the transaction for the
      items that need shipping not until the items ship.</p>

    <p>When a shipment is made, if it's a full shipment of the order,
      the financial transactions inserted when the order is first
      placed are ready to be captured. (The field
      <code>to_be_captured_p</code> of the financial transactions
      become 't' and @package_name@ attempts to capture it.)</p>

    <p>However, if only a partial shipment is made, a new
      authorization has to be made (therefore a new row is inserted
      into <code>ec_financial_transactions</code>,
      <code>to_be_captured_p</code> is set to 't' and the system
      attempts to mark and capture it).

    <p>When a refund is made, a row is also inserted into
      <code>ec_financial_transactions</code>.  A refund is only
      inserted if it is definite that it needs to be captured, so
      there is no need to set <code>to_be_captured_p</code> if
      <code>transaction_type</code>='refund'.</p>

    <p>Scheduled procs go around and do the follow-through (making
      sure everything is marked/settled) for every transaction that
      needs to be captured.</p>

  </blockquote>
  
  <h3>Gift Certificates</h3>

  <blockquote>
    
    <p>Each customer has a gift certificate balance (it may be $0.00),
      which you can determine by calling the PL/SQL function
      <code>ec_gift_certificate_balance</code>.  Different chunks of a
      customer's balance may expire at different times because every
      gift certificate that is issued has an expiration date.</p>

    <p>When the system applies a customer's gift certificate balance
      to an order, it begins by using the ones that are going to
      expire the soonest and continues chronologically until either
      the order is completely paid for or until the customer's gift
      certificates run out.  If only part of a gift certificate is
      used, the remaining amount can be used later.</p>

    <p>If a customer purchases a gift certificate for someone else,
      the recipient (who may or may not be a registered user of the
      site) is emailed a claim check that they can use to retrieve the
      gift certificate and have it placed in their gift certificate
      balance.  Note: "retrieving" a gift certificate is equivalent to
      inserting the <code>user_id</code> of the owner into
      <code>ec_gift_certificates</code>.  Retrieved gift certificates
      always belong to registered users because gift certificates can
      only be retrieved during the course of placing an order, at
      which time an unregistered user becomes registered.</p>

    <p>Site administrators can issue gift certificates to customers at
      will.  In this case, no claim check is generated.  The gift
      certificate is automatically assigned to that
      <code>user_id</code>.</p>

  </blockquote>

  <h3>Order States</h3>

  <blockquote>

    <p>Order states are discussed in detail in <a
     href="ecommerce-operation">Operation of the Ecommerce Module</a>.
     That should be read to understand the concepts of order states
     and item states and to see the finite state machines involved.</p>

    <p>Below is a very boring diagram of what order state the order
      should be in given the item state of the items in that order.
      This diagram only covers the order states VOID,
      PARTIALLY_FULFILLED, FULFILLED, and RETURNED.  All other order
      states are grouped under OTHER.  In all other order states, the
      items are of a uniform item state, so it is either quite obvious
      what the order state will be or it is completely independent of
      what the order state will be.</p>

    <p>An "X" in a column implies that there is at least one (possibly
      many) item in that item state.</p>

    <table border>
	<tr>
	  <th colspan=4>Item State</th><th rowspan=2>Order State</th>
	<tr>
	  <th>
	    VOID
	  </th>
	  <th>
	    RECEIVED_BACK
	  </th>
	  <th>
	    SHIPPED
	  </th>
	  <th>
	    OTHER
	  </th>
	</tr>

	<tr>
	  <td align=center>
	    X
	  </td>
	  <td align=center>
	    X
	  </td>
	  <td align=center>
	    X
	  </td>
	  <td align=center>
	    X
	  </td>
	  <td align=center>
	    PARTIALLY_FULFILLED
	  </td>
	</tr>

	<tr>
	  <td align=center>
	    X
	  </td>
	  <td align=center>
	    X
	  </td>
	  <td align=center>
	    X
	  </td>
	  <td align=center>
	    0
	  </td>
	  <td align=center>
	    FULFILLED
	  </td>
	</tr>

	<tr>
	  <td align=center>
	    X
	  </td>
	  <td align=center>
	    X
	  </td>
	  <td align=center>
	    0
	  </td>
	  <td align=center>
	    X
	  </td>
	  <td align=center>
	    PARTIALLY_FULFILLED
	  </td>
	</tr>

	<tr>
	  <td align=center>
	    X
	  </td>
	  <td align=center>
	    X
	  </td>
	  <td align=center>
	    0
	  </td>
	  <td align=center>
	    0
	  </td>
	  <td align=center>
	    RETURNED
	  </td>
	</tr>

	<tr>
	  <td align=center>
	    X
	  </td>
	  <td align=center>
	    0
	  </td>
	  <td align=center>
	    X
	  </td>
	  <td align=center>
	    X
	  </td>
	  <td align=center>
	    PARTIALLY_FULFILLED
	  </td>
	</tr>

	<tr>
	  <td align=center>
	    X
	  </td>
	  <td align=center>
	    0
	  </td>
	  <td align=center>
	    0
	  </td>
	  <td align=center>
	    X
	  </td>
	  <td align=center>
	    OTHER
	  </td>
	</tr>

	<tr>
	  <td align=center>
	    X
	  </td>
	  <td align=center>
	    0
	  </td>
	  <td align=center>
	    0
	  </td>
	  <td align=center>
	    0
	  </td>
	  <td align=center>
	    VOID
	  </td>
	</tr>


	<tr>
	  <td align=center>
	    0
	  </td>
	  <td align=center>
	    X
	  </td>
	  <td align=center>
	    X
	  </td>
	  <td align=center>
	    X
	  </td>
	  <td align=center>
	    PARTIALLY_FULFILLED
	  </td>
	</tr>

	<tr>
	  <td align=center>
	    0
	  </td>
	  <td align=center>
	    X
	  </td>
	  <td align=center>
	    X
	  </td>
	  <td align=center>
	    0
	  </td>
	  <td align=center>
	    FULFILLED
	  </td>
	</tr>

	<tr>
	  <td align=center>
	    0
	  </td>
	  <td align=center>
	    X
	  </td>
	  <td align=center>
	    0
	  </td>
	  <td align=center>
	    X
	  </td>
	  <td align=center>
	    PARTIALLY_FULFILLED
	  </td>
	</tr>

	<tr>
	  <td align=center>
	    0
	  </td>
	  <td align=center>
	    X
	  </td>
	  <td align=center>
	    0
	  </td>
	  <td align=center>
	    0
	  </td>
	  <td align=center>
	    RETURNED
	  </td>
	</tr>

	<tr>
	  <td align=center>
	    0
	  </td>
	  <td align=center>
	    0
	  </td>
	  <td align=center>
	    X
	  </td>
	  <td align=center>
	    X
	  </td>
	  <td align=center>
	    PARTIALLY_FULFILLED
	  </td>
	</tr>

	<tr>
	  <td align=center>
	    0
	  </td>
	  <td align=center>
	    0
	  </td>
	  <td align=center>
	    0
	  </td>
	  <td align=center>
	    X
	  </td>
	  <td align=center>
	    OTHER
	  </td>
	</tr>
    </table>

  </blockquote>

  <h3>Shopping Cart Definitions</h3>

  <blockquote>
    <dl>
      <dt>Shopping Cart</dt>

      <dd>An IN_BASKET order with the same user_session_id as in the
      user's cookie.</dd>

      <dt>Saved Cart</dt>

      <dd>An IN_BASKET order with the user_id filled in, no
	user_session_id filled in, and saved_p='t'</dd>

      <dt>Abandoned Cart</dt>

      <dd>An IN_BASKET order with saved_p='f' and a user_session_id
	that doesn't correspond to the user_session_id in anyone's
	cookie (e.g. the user's cookie expired or they turned cookies
	off).  There's no way of determining whether a shopping cart
	has been abandoned.  These are different from expired orders
	which are automatically put into the order state EXPIRED if
	they're still IN_BASKET after N days, where N is set in the
	@package_name@ parameters.)
    </dl>
  </blockquote>

  <h3>Credit Card Pre-Checking</h3>

  <blockquote>

    <p> Before credit card information is sent out to the payment
      gateway for authorization, some checking is done by the module
      to make sure that the credit card number is well-formed (using
      the procedure <code>ec_creditcard_precheck</code> which can be
      found in /tcl/ecommerce-credit).  The procedure checks the
      length of the credit card number, makes sure it starts with the
      right digit for the card type, and does a LUHN-10 check (that's
      a checksum which can't determine whether the number is a valid
      credit card number but which determines whether it's even
      <i>possible</i> for it to be a valid credit card number).</p>

    <p>This procedure only encompasses the three most common credit
      card types: MasterCard, Visa, and American Express.  It can
      quite easily be extended to include other credit card types.</p>

  </blockquote>

  <h3>Automatic Emails</h3>

  <blockquote>

    <p>When you install the system, there are 7 automatic emails
      included that are sent to customers in common situations (e.g.,
      "Thank you for your order" or "Your order has shipped").  If a
      site administrator adds a new email template using the admin
      pages, you will have to create a new procedure that does all the
      variable substitution, the actual sending out of the email, etc.
      This should be easy.  Just copy any one of the 7 autoemail
      procedures in /tcl/ecommerce-email (<i>except</i> for
      <code>ec_email_gift_certificate_recipient</code>, which is
      unusual).  Then invoke your new procedure anywhere appropriate
      (e.g. the email that says "Thank you for your order" is invoked
      by calling <code>ec_email_new_order $order_id</code> after the
      order has been successfully authorized).</p>

  </blockquote>

  <h3>Storage of Credit Card Numbers</h3>

  <blockquote>

    <p>Credit card numbers are stored until an order is completely
      fulfilled.  This is done because a new charge might need to be
      authorized if a partial shipment is made (we are forced to
      either capture the amount that a charge was authorized for or to
      capture nothing at all - we can't capture any amount in between;
      therefore, we are forced to do a new authorization for each
      amount we are going to charge the user).  A new charge also
      might need to be authorized if a user has asked the site
      administrator to add an item to their order.</p>

    <p>If you've decided not to allow customers to reuse their credit
      cards, their credit card data is removed periodically (a few
      times a day) by <code>ec_remove_creditcard_data</code> in
      /tcl/ecommerce-scheduled-procs (it removes credit card numbers
      for orders that are FULFILLED, RETURNED, VOID, or EXPIRED).</p>

    <p>If you've decided to allow customers to reuse their credit
      cards, their credit card information is stored indefinitely.
      This is not recommended unless you have top-notch, full-time,
      security-minded system administrators.  The credit card numbers
      are not encrypted in the database because there isn't much point
      in doing so; our software would have to decrypt the numbers
      anyway in order to pass them off to the payment gateway, so it
      would be completely trivial for anyone who breaks into the
      machine to grep for the little bit of code that decrypts them.
      The ideal thing would be if payment gateways were willing to
      develop a system that uses PGP so that we could encrypt credit
      card numbers immediately, store them, and send them to the
      payment gateway at will.  <i>Philip and Alex's Guide to Web
      Publishing</i> says:</p>

    <blockquote>

      <p>What would plug this last hole is for a payment gateway to
	give us a public key. We'd encrypt the consumer's card number
	immediately upon receipt and stuff it into our Oracle
	database. Then if we needed to retry an authorization, we'd
	simply send the payment gateway a message with the encrypted
	card number. They would decrypt the card number with their
	private key and process the transaction normally. If a cracker
	broke into our server, the handful of credit card numbers in
	our database would be unreadable without the payment gateway's
	private key. The same sort of architecture would let us do
	reorders or returns six months after an order.</p>

    </blockquote>

    <p>Note 1: The above discussion <i>does not</i> mean that the
      credit card numbers go over the network unencrypted.  Most
      payment gateways use secure connections.</p>

    <p>Note 2: If you want to let your customers reuse their old
      credit cards, you can reduce some of the risk by manually
      removing old credit card data once in a while (at least then
      there will be fewer numbers in your database for the crackers to
      steal).  To clear out the unnecessary credit card data, just run
      a procedure like <code>ec_remove_creditcard_data</code> (in
      /tcl/ecommerce-scheduled-procs) but get rid of the if statement
      that checks whether <code>SaveCreditCardDataP</code> is 0 or 1.</p>

  </blockquote>

  <h3>Price Calculation</h3>

  <blockquote>

    <p>The site administrator can give the same product different
      prices for different classes of users.  They can also put
      products on sale over arbitrary periods of time (sale prices may
      be available to all customers or only to ones who have the
      appropriate <code>offer_code</code> in their URL).</p>

    <p>The procedure
      <code>ec_lowest_price_and_price_name_for_an_item</code> in
      /tcl/ecommerce-money-computations determines the lowest price
      that a given user is entitled to receive based on what user
      classes they're in and what <code>offer_code</code>s they came
      to product with.  Their <code>offer_code</code>s are stored,
      along with their <code>user_session_id</code>, in
      <code>ec_user_session_offer_codes</code> (we decided to store
      this in the database instead of in cookies because it was a
      slightly more efficient method, although either implementation
      would have worked).  One minor complication to this is that if a
      user saves their shopping cart, we want them to get their
      special offer price, even though they may be coming back with a
      different <code>user_session_id</code>; therefore, upon
      retrieving saved carts, the <code>offer_code</code>s are
      inserted again into <code>ec_user_session_offer_codes</code>
      with the user's current <code>user_session_id</code> (we had to
      associate <code>offer_code</code>s with
      <code>user_session_id</code> as opposed to <code>user_id</code>
      because someone with an <code>offer_code</code> shouldn't be
      prevented from seeing the special offer price if they haven't
      logged in yet).</p>
  </blockquote>

  <p>The above items are just things that I've found myself explaining
    to others or things that I think will be useful for people
    extending this module.  Obviously the bulk of the module's code
    has not been discussed here. If you have any questions, please
    email Eve at <a
    href="mailto:eveander@arsdigita.com">eveander@arsdigita.com</a> or
    Janine at <a href="mailto:janine@furfly.net">janine@furfly.net</a>


