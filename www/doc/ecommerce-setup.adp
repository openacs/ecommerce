<master>
  <property name=title>Setup of the Ecommerce Module</property>
  <property name="signatory">@signatory@</property>
  <property name="context_bar">@context_bar@</property>

  <p>This is intended to be a guide for the content administrators of
    @package_name@.  Content administrators are not assumed to have any
    technical expertise (although HTML knowledge is necessary if you
    want to edit product templates).</p>

  <p> These are the basic steps needed to get @package_name@ up and
    running.  Most functions below can be performed using the
    @package_name@ administration pages in <if @package_url@ not nil><a
    href="@package_url@admin/">@package_url</if>@admin/<if @package_url@ not nil></a></if> (must be
    accessed using HTTPS).</p>

  <ol>
    <li>
      
      <p>First make sure that the <a
	href="ecommerce-technical">technical setup</a> has been taken
	care of.  Although most of it can be done quickly, the process
	of setting up a merchant account to accept credit cards can
	take weeks, so don't procrastinate!</p>

      <p>You will need to answer the following questions for whomever
	will be administring @package_name@ site parameters, and for
	those individuals adding products or services to your
	site.</p>

      <p>If you don't know what some of these questions mean, read on.
	These should make sense after you've finished reading this
	page.</p>

      <ol type="A">

	<li><p>What units of currency and weight (e.g. USD and lbs) will be used
	  throughout the site.</p></li>

	<li><p>Whether you are selling hard goods that require
	  shipping and/or soft goods and services that are not being
	  shipped.</p></li>

	<li><p>How many products to display per page when the customer is
	  browsing (default 10).</p></li>

	<li><p>Whether to allow users to write public comments of the products
	  and, if so, whether the comments need to be approved (by you) before
	  they appear on the site.</p></li>

	<li><p>Whether you want product relationships (e.g. "people who bought
	  product A also bought products B, C, and D") to be calculated and
	  displayed</p></li>

	<li><p>Regarding user classes (i.e., classes that you might place users
	  in like "publisher" or "student" for purposes of giving discounts or
	  different views of the site):</p> 
	  
	  <ol type="a">
	    <li><p>Do you want them to know what classes they're
	      in?</p></li>

	    <li><p>Can they request via the web site to be placed into
	      user classes, and</p></li>

	    <li><p>if so, do they automatically become a member of
	      any user class they request to be a part of, or do their
	      requests need to be approved by an administrator
	      first?</p></li>
	  </ol>
	</li>

	<li><p>What percentage of the shipping charges should be refunded if a
	  customer returns their purchases.</p></li>

	<li>
	  <p>Whether express shipping, and pickups at your location are available.</p>
	</li>

	<li><p>Whether you want to save credit card data (if so, customers can
	  reuse their credit card with one click; if not, the credit card number
	  is deleted after the order has shipped).</p></li>

	<li><p>How large you want the automatically-generated thumbnail images of
	  the products to be (you can specify either the width or the height, in
	  pixels; the dimension you don't specify will vary based on the
	  original image's size).</p></li>

	<li><p>What product stock messages you want to be able to choose from
	  when adding/editing products (e.g. "Out of Stock", "Usually Ships
	  Within 24 Hours", "Usually Ships Within 2-3 Days", etc.).</p></li>

	<li><p>The number of days a user's shopping cart will stay valid before
	  it goes into the 'expired' state.</p></li>

	<li><p>Whether to allow preorders for items that are not yet
	available.</p></li>

	<li><p>The email address that will be used for all email sent from the
	  system to the customers.</p></li>

	<li><p>Whether people fulfilling the orders should be alerted if there's
	  a problem reauthorizing a credit card for payment (which happens when
	  orders are shipped) -- you'll want them to be alerted if they're in a
	  position to do anything about the problem (e.g. abort the shipment);
	  otherwise, there's no need to alert them because the problem will
	  still be logged so that someone else can take care of it.</p></li>

	<li><p>Whether customers are allowed to purchase gift certificates for
	  others and, if so, the minimum and maximum amounts of money that the
	  gift certificates can be worth as well as the number of months until
	  the gift certificates expire.</p></li>

      </ol>

    <li>

      <p>Set up product categorization (<if @package_url@ not nil><a
       href="@package_url@admin/cat/">@package_url@</if>admin/cat/<if @package_url@ not nil></a></if>):</p>

      <p>Product categories, subcategories and subsubcategories are
	optional, but if you intend to offer many products for sale,
	it is best to think about how they should be categorized
	<i>before</i> you enter any products into the database.  The
	categorization is used when displaying the products and when
	the customer is searching for products.</p>

      <p> Here is an example to help you decide how you want to
	categorize your products.  Say you are a publisher and you are
	selling a variety of books and periodicals.  You may wish to
	divide your goods into two categories: books and periodicals.
	The subcategories of books will be: fiction, biography,
	history, science, and so on.  The subcategories of periodicals
	will be: health &amp; fitness, sports, news, beauty, and so
	on.  If you want to go a level deeper, you can subdivide
	science, for instance, into physics, chemistry, biology,
	geology, and so on.</p>

      <p>Another example: say you sell CDs and nothing else.  Then
	your categories can be: classical, rock, jazz, international,
	etc.  You will probably not need to use subcategories.</p>

      <p>What if one of your products spans two categories?  That's
	OK; you are allowed to put a product into as many categories
	(and subcategories and subsubcategories) as you like.  So, if
	you're selling the <i>Girl From Ipanema</i> CD, you can put it
	into both the jazz and the international categories so that
	your customers can find it in both places.</p>

    </li>

    <li>

      <p>Set up your shipping cost rules (<if @package_url@ not nil><a
        href="@package_url@admin/shipping-costs/">@package_url@</if>admin/shipping-costs/<if @package_url@ not nil></a></if>).
        @package_name@ is flexible regarding how you charge your
        customers for shipping. The <if @package_url@ not nil><a
        href="@package_url@admin/shipping-costs/"></if>Shipping Costs
        page<if @package_url@ not nil></a></if> in the admin section will lead you through it.  Make
        sure you read the <if @package_url@ not nil><a
        href="@package_url@admin/shipping-costs/examples"></if>Shipping
        Cost Examples page<if @package_url@ not nil></a></if> if you don't already know how you want
        to set it up.</p> 

      <p>Check out the <if @shipping_gateway_installed@><a
        href="/doc/shipping-gateway/"></if>Shipping Service
        Contract<if @shipping_gateway_installed@></a></if> if the
        default @package_name@ shipping cost rules don't allow you to
        specify the rules you want. With the Shipping Service Contract
        installed you can select an implementation of the contract
        that fills your needs and it will supersede the @package_name@
        shipping rules. (Including the express shipping and pickup at
        location options.)</p>

    </li>

    <li>

      <p>Set up your sales tax rules (<if @package_url@ not nil><a
        href="@package_url@admin/sales-tax/"
        >@package_url@</if>admin/sales-tax/<if @package_url@ not nil></a></if>).  If your company is
        located only in one or a few states, this will be easy.  On
        the other hand, if you're a Fortune 500 company and you have
        nexus (i.e. have an office or factory or store) in many
        states, you might want to buy tax tables from <a
        href="http://www.salestax.com/">www.salestax.com</a>.  A fair
        bit of programming would be needed to integrate this data with
        @package_name@.  Also if you're not based in the USA, you may
        need to have some programming done to handle the tax for the
        regions in your country.</p>

    </li>

    <li>

      <p>Decide if you want to add any custom product fields.  First
        look at the current fields available (<if @package_url@ not nil><a
        href="@package_url@admin/products/add"
        >@package_url@</if>admin/products/add<if @package_url@ not nil></a></if>) to see if they meet your
        needs.  The current fields are probably sufficient for many
        types of products.  However, a bookseller may wish to add a
        custom field to store the ISBN, or someone who sells clothing
        from many manufacturers may wish to add a manufacturers field.
        Custom fields are added at <if @package_url@ not nil><a
        href="@package_url@admin/products/custom-fields">@package_url@</if>
	admin/products/custom-fields<if @package_url@ not nil></a></if>.</p>

    </li>

    <li>

      <p>Create new product display templates (<if @package_url@ not nil><a
	href="@package_url@admin/templates/">@package_url@</if>admin/templates/<if @package_url@ not nil></a></if>)
	(unless you're happy with the somewhat minimalist default
	template).  The reason for having product display templates is
	that you might want to present different types of products in
	different ways (e.g., spring dresses get a yellow background
	page color; winter coats get a blue background page color).</p>

      <p>You can modify the default template that @package_name@ comes
	with to incorporate your custom product fields, to exclude
	fields you don't use, or just change the way it looks to fit
	whatever design scheme you want to use.  The template is
	written in AOLserver's ADP language, which is just HTML with
	Tcl variables (or commands) inside &lt;% and %&gt; tags.  It
	is extremely easy.  It you can write HTML, you can write ADP.
	If you can't, you can hire someone cheaply to do it for
	you.</p>

	<p>You can create as many additional templates as you like.
	You can associate templates with product categories so that
	every product in the "book" category is automatically assigned
	the "book" template by default, although you can always assign
	any template you want to any product you want (so if you have
	an unusual product, you can give it an unusual template).</p>

    </li>

    <li>

      <p>Set up user classes (<if @package_url@ not nil><a
        href="@package_url@admin/user-classes/"
        >@package_url@</if>admin/user-classes/<if @package_url@ not nil></a></if>).  User classes are
        groupings of the users, such as "student", "retired",
        "institution", "publisher", etc. They may get special prices,
        different views of the site, or different product
        recommendations.</p>

      <p>Depending on your settings in the ini file, users may or may
	not be able to see which user classes they're a member of (so
	be careful of what you call them!).</p>

      <p>If a user is a member of more than one class and there are
	special prices on the same product for both classes, the user
	will receive whichever price is lowest.</p>

    </li>

    <li>

      <p>Enter your products into the database.  This can be done
        using the simple form at <if @package_url@ not nil><a
        href="@package_url@admin/products/add"
        >@package_url@</if>admin/products/add<if @package_url@ not nil></a></if>.</p>

      <p>However, if you have many products already stored in another
	database, you will not want to enter them one by one.
	Instead, export them into a CSV file (or a series of CSV
	files), and manipulate them into the formats documented at <if @package_url@ not nil><a
	href="@package_url@admin/products/upload-utilities"
	>@package_url@</if>admin/products/upload-utilities<if @package_url@ not nil></a></if> so that they
	can be uploaded in bulk.</p>

    </li>

    <li>
      <p>After you've added a product, there are a variety of things
        you can do to it, such as:</p>
      <ul>
	<li>Add any number of professional reviews.</li>

	<li>Add "cross-selling links" so that the customer always sees
	  a link to another given product when they're viewing this
	  product, or vice versa.</li>

	<li>Put the product on sale or create "special offers".</li>
      </ul>
    </li>

    <li>

      <p>Add product recommendations (<if @package_url@ not nil><a
	href="@package_url@admin/products/recommendations">@package_url@</if>dmin/products/recommendations<if @package_url@ not nil></a></if>).
	If you have many products subdivided into a number of
	categories/subcategories/subsubcategories, it's good to
	include product recommendations in order to make the site more
	browsable and interesting.</p>

      <p>Recommendations are displayed when the customer is browsing
	the site, either on the home page (if a product is recommended
	at the top level), or when the customer is browsing
	categories, subcategories, or subsubcategories.</p>

      <p>You can also associate product recommendations with a user
	class.  E.g., you might only want the book "Improving your GRE
	Scores" to only be recommended to Students.</p>

    </li>

    <li>

      <p>Modify the email templates (<if @package_url@ not nil><a
	href="@package_url@admin/email-templates/">@package_url@</if>admin/email-templates/<if @package_url@ not nil></a></if>),
	which are used when the system sends out automatic email to
	customers.  There are seven predefined email templates for
	email sent out when a customer's order is authorized, when a
	customer's order ships, when a customer receives a gift
	certificate, etc.</p>

      <p>The current templates are functional but should probably be
	edited to reflect your company better.</p>

    </li>

    <li>The layout for all the pages in your site is created using ADP templates
      which are stored in the directory packages/ecommerce/www/templates/
      (with the exception of product which, as discussed above, uses a different
      ADP templating system to allow for different templates for different products).
      If you are unhappy with the look of any of the pages in your site, there's
      a good chance that it can be changed simply by editing the corresponding ADP
      template.</li>

  </ol>

  <p>That's it for setup!  Of course, your customers won't be very
    happy until you can do things like order fulfillment, so it's time
    to read about <a href="ecommerce-operation">operation of
    @package_name@</a>.</p>
