<master>
  <property name=title>Operation of the Ecommerce Module</property>
  <property name="signatory">@signatory@</property>
  <property name="context_bar">@context_bar@</property>

  <p>Before reading this, make sure that you have read about <a
   href="ecommerce-setup">setting up your ecommerce module</a>.  This
   document takes up where that one leaves off and covers all the
   components of operating your on-line shop with the exception of <a
   href="ecommerce-customer-service">customer service</a>, which is a
   module in itself.</p>
  
  <h3>Orders</h3>
  
  <p>These are the states that an order can go through:</p>

  <blockquote>
    <pre>
   +-------- IN_BASKET <----------------+ (if authorization fails --
   |            |                       | it might also temporarily go
   |            |                       | into FAILED_AUTHORIZATION
EXPIRED      CONFIRMED------------------+ before returning to IN_BASKET)
                |
                |
            AUTHORIZED
                |
                |
                +-----------------+
                |                 |
                |                 |
       PARTIALLY_FULFILLED--->FULFILLED
                                  |
                                  |
                               RETURNED
    </pre>
  </blockquote>

  <p>An order can also be put into the VOID state at any time by the
    site administrator.  (Note: these states are actually stored in
    all lowercase in the database, but it's clearer to use uppercase
    letters in the documentation.)</p>
  
  <p>An order is IN_BASKET when the customer has put items into their
    shopping cart on the site but has not indicated an intent to buy
    (if they stay there too long they go into the EXPIRED state; "too
    long" is defined in the parameters/yourservername.ini file;
    default is 30 days).  When the customer submits their order, the
    state becomes CONFIRMED.  Only then do we try to authorize their
    credit card.  If the authorization succeeds, the order state will
    be updated to AUTHORIZED. If an order fails, it goes back into the
    IN_BASKET state and the customer is given another chance to enter
    their credit card information.</p>

  <p>Problems occur if we don't hear back from the payment gateway or
    if they give us a result that is inconclusive.  In cases like
    this, the order state remains in the CONFIRMED state.  A scheduled
    procedure sweeps the database every once in a while looking for
    CONFIRMED orders that are over 15 minutes old and tries to
    authorize them.  If the authorization succeeds, the order is put
    into the AUTHORIZED state.  If it fails, it is temporarily put
    into the FAILED_AUTHORIZATION state so that it can be taken care
    of by a scheduled procedure which sends out email to the customer
    saying that we couldn't authorize their order and then saves the
    order for them (a saved order is one in the IN_BASKET state with
    saved_p='t'; it can be retrieved easily by the customer
    later).</p>

  <p>Once an order is authorized they are ready to be shipped.  An
    order which has some of its items shipped is PARTIALLY_FULFILLED
    and orders for which a full shipment is made are FULFILLED.  It
    remains in the fulfilled state unless <i>all</i> of the items in
    the order are returned, at which time it becomes financially
    uninteresting and goes into the RETURNED state.</p>

  <p>Individual items in an order also go through a series of states:</p>

  <blockquote>
    <pre>
IN_BASKET -----------+
   |                 |
TO_BE_SHIPPED     EXPIRED
   |
SHIPPED
   |
ARRIVED
   |
RECEIVED_BACK
    </pre>
  </blockquote>

  <p>An item starts out in the IN_BASKET state.  When the order it's
      in becomes authorized, the item becomes TO_BE_SHIPPED.  Because
      partial shipments can be made on orders, SHIPPED is a state of
      the individual items, not of the order.  There is currently no
      mechanism for putting an item into the ARRIVED state but it
      could be used if you were to set up a method of data exchange
      with FedEx's database to get the actual arrival date and arrival
      detail for each of the packages you ship.  If the customer
      returns an item to you, it is put into the RECEIVED_BACK state.
      Like orders, individual items can also be put into the VOID
      state (e.g. if the customer changes their mind or if you run out
      of stock before you can ship it).</p>

    <p>OK, so what can you actually do with orders?  You can:</p>

    <ul>
      <li><if @package_url@ not nil><a href="@package_url@admin/orders/by-order-state-and-time"></if>view them<if @package_url@ not nil></a></if></li>
      <li><if @package_url@ not nil><a href="@package_url@admin/orders/fulfillment"></if>fulfill them<if @package_url@ not nil></a></if></li>
      <li><if @package_url@ not nil><a href="@package_url@admin/orders/"></if>search for individual orders<if @package_url@ not nil></a></if></li>
    </ul>
    
    <p>On an individual order, you can:</p>

    <ul>
      <li>add comments to it</li>
      <li>record a shipment</li>
      <li>process a refund</li>
      <li>add items (only if it hasn't shipped yet and if it was paid
	for using a credit card instead of using a gift
	certificate)</li>
      <li>change the shipping address</li>
      <li>change the credit card information</li>
      <li>void it</li>
    </ul>

    <h3>Gift Certificates</h3>

  <p>As you know from <a href="ecommerce-setup">setting up your
   ecommerce module</a>, you can configure whether to allow customers
   to purchase gift certificates for others.  These are the states
   that a purchased gift certificate goes through:</p>

  <blockquote> 
    <pre>
           CONFIRMED
               |
        +------+------+
        |             |
AUTHORIZED   FAILED_AUTHORIZATION
    </pre>
  </blockquote>

  <p>Regardless of whether you allow customers to purchase gift
    certificates, you can always issue gift certificates to your
    customers.  Gift certificates that you issue automatically go into
    the AUTHORIZED state.</p>

  <p>There are a few fundamental ways in which purchased gift
    certificates differ from assigned gift certificates.  Purchased
    gift certificates are sent to some recipient who may or may not be
    a registered user of the system, along with a claim check.  These
    gift certificates must be claimed upon order checkout in order to
    be used.  Issued gift certificates, on the other hand, are given
    to registered users of the system and are put directly into their
    gift certificate balance.  There is no need for them to be claimed
    because there is no ambiguity about who the gift certificates
    belong to.</p>

  <p>All gift certificates have an expiration date (this is necessary
    so that your liability has a definite ending point).  A customer's
    gift certificate balance is equal to the sum of all the unused
    portions of each non-expired gift certificate they own.  When
    their gift certificate balance is applied toward a new order, the
    gift certificates that expire soonest are the first to be
    applied.</p>

  <p>Things you can do with gift certificates:</p>

  <ul>
    <li>view <if @package_url@ not nil><a href="@package_url@admin/orders/gift-certificates"></if>purchased
	gift certificates<if @package_url@ not nil></a></if></li>
    <li>view <if @package_url@ not nil><a href="@package_url@admin/orders/gift-certificates-issued"></if>issued
        gift certificates<if @package_url@ not nil></a></if></li>
    <li>see your <if @package_url@ not nil><a href="@package_url@admin/orders/revenue"></if>gift certificate
	liability<if @package_url@ not nil></a></if></li>
    <li>see a customer's gift certificates (find the customer using
        the customer service module or <a
        href="/acs-admin/users/">/acs-admin/users</a>) and void their gift
        certificates or issue them new ones</li>
  </ul>

  <h3>Site Upkeep</h3>

  <p>Besides the most important task of filling orders, there are some
    other things that need to be done once in a while.</p>

  <p>Naturally, you'll want to rotate your <if @package_url@ not nil><a
     href="@package_url@admin/products/recommendations"></if>product
     recommendations<if @package_url@ not nil></a></if> every so often to keep your site looking
     fresh, even if your product database doesn't change.  You will
     also need to periodically <if @package_url@ not nil><a
     href="@package_url@admin/customer-reviews/"></if>approve/disapprove
     customer reviews<if @package_url@ not nil></a></if> (if you've set reviews to require approval)
     and perhaps view <if @package_url@ not nil><a href="@package_url@admin/orders/"></if>some reports<if @package_url@ not nil></a></if>
     to make sure everything is going as you expected.</p>

  <h3>Dealing with Problems</h3>

  <p>A <if @package_url@ not nil><a href="@package_url@admin/problems/"></if>log of potential problems<if @package_url@ not nil></a></if>
    is maintained by the system when it comes across issues that it is
    unable to resolve.  These problems (hopefully infrequent) will
    need to be resolved by hand.</p>

  <p>Continue on to the <a href="ecommerce-customer-service">Customer
   Service Module</a>.</p>
