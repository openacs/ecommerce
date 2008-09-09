<master>
  <property name=title>@title;noquote@</property>
  <property name="signatory">@signatory;noquote@</property>
  <property name="context_bar">@context_bar;noquote@</property>

  <h2>Some of the high-level features of the @package_name@:</h2>

  <h3>Products</h3>

  <ul>

    <li>Products are divided into categories (like books, journals,
      ...), subcategories (computer, fiction, ...), and
      subsubcategories (operating systems, web publishing, ...)  which
      are set by the site adminstrator (if desired).  Products can
      belong to as many categories / subcategories / subsubcategories
      as needed. Users can search by category / subcategory /
      subsubcategory and the site administrator can make product
      recommendations by category / subcategory / subsubcategory.</li>

    <li>The site administrator can upload any
      desired information about products either into the database or
      into the file system.  Standard product information such as
      product name, regular price, etc., and admin-defined custom
      fields are collected in the database.  Pictures of the product
      and other formatted info like sample chapters, for instance, are
      uploaded into the file system.</li>


    <li>Users can input comments and ratings of products.  The site
      administrator can choose to:</li>

  <ol type="a">
    <li>allow all comments,</li>
    <li>allow comments after administrator approval, or </li>
    <li>disallow allow comments.</li>
  </ol>

    <li>The site administrator can input professional reviews of the
      products.</li>

    <li>The site administrator can specify whether the product should
      be displayed when the user does a search. For example, they
      might not want the product to display if the product is part of
      a series or if the product is the hardcover version of a book
      that also exists in paperback.</li>

    <li>Links between products: the site administrator can specify
      that one product always links to other product(s) on the
      product-display page.</li>

    <li>Products can be listed before they are available for sale.
      The site administrator decides whether customers are allowed to
      preorder items or if they are not allowed to order until the
      date that the products become available.</li>
    
    <li>A product can have a lower, introductory price.  It can also
      have a limited-time sale price, and a limited-time special offer
      price which is given only to those who have the special offer
      code in their URL.</li>

    <li>The site administrator determines the geographical regions in
      which tax should be charged.</li>

    <li>Shipping costs are determined by the site administrator as a
      base cost + a certain amount per additional item, or the cost
      can be based on weight.  Additional amounts are charged for
      express shipping, if allowed. Alternatively, the shipping costs
      can be obtained from an implementation of the <if
      @shipping_gateway_installed@ eq 1><a
      href="/doc/shipping-gateway"></if>Shipping Service Contract<if
      @shipping_gateway_installed@ eq 1></a></if>.</li>

  </ul>

  <h3>Personalization</h3>

  <ul>

    <li>Users are recognized, if possible, when they enter the site.</li>

    <li>Users can be placed into user classes (student, publisher,
      ...)  either by themselves (with site administrator approval) or
      by the site administrator.</li>

    <li>Members of user classes can be given different views of the
      site, different prices for each product, and different product
      recommendations.</li>

    <li>A user's purchasing history as well as browsing history is
      stored.  Product recommendations can be made based on both
      histories.</li>

    <li>Frequent buyers can be recognized and rewarded.</li>

    <li>The site will automatically calculate what other products were
      most popular among people who bought a given product.</li>

  </ul>

  <h3>Ordering</h3>

  <ul>

    <li>Shopping cart interface: users select items to put into their
      shopping cart and then go to their cart when they want to "check
      out".  The shopping cart is editable (similar to Amazon.com).</li>

    <li>If a user is not ready to order yet, they can store their
      order and come back to it later (similar to Dell.com).</li>

    <li>User receives an acknowledgment web page and email when their
      order is confirmed.</li>

    <li>The user can reuse an address for billing or shipping that
      they previously entered on the site and, if the site
      administrator has chosen to store credit card data, they can
      reuse previous credit cards.</li>

    <li>The user's credit card is authorized at the time that they
      confirm their order.  The card is billed automatically only
      after the site administrator marks that the order has been
      shipped. With the exception of items that do not require
      shipping (so called 'soft goods'). Soft goods are billed
      immediately after the card has been authorized for the soft good
      total amount.</li>

    <li>The site administrator can issue electronic gift certificates
      to users.</li>
    
    <li>The site administrator is able to give refunds to a user if
      the user returns all or part of their order.</li>

    <li>Customers can view their order history and track their
      packages.</li>

    <li>Customers can purchase gift certificates for other people.  A
      random claim check is generated at the time of purchase and
      emailed to the recipient.  The recipient is then able to use
      their gift certificate when they make purchases on the site
      (until the certificate expires).</li>

  </ul>

  <h3>Community</h3>

  <ul>

    <li>Users can sign up for mailing lists based on the product
      categories they are interested in.</li>

    <li>Most importantly, since the @package_name@ is tied in with the
      rest of the Open Architecture Community System, a more complete
      picture of the customer (Q &amp; A forum postings, Classified
      Ads, etc.)  is known than in a stand-alone ecommerce
      system.</li>

  </ul>

  <h3>Customer Service</h3>

  <ul>

    <li>A complete customer service submodule which allows customer
      service reps to: </li>
    
  <ul>
    <li>Receive and respond to customer inquiries via email (includes
      a spell-checker!).</li>

    <li>Record all customer interactions and issues (whether by
      phone/fax/email/etc.).</li>

    <li>Categorize issues.</li>

    <li>View complete customer interaction and purchase
      histories.</li>

    <li>Send email using the "canned text" system which allows them to
      automatically insert commonly-used paragraphs into their
      emails.</li>

    <li>Contact groups of users based on various criteria (date of last
      visit, number of purchases, pages they've visited, mailing lists
      they've signed up for, etc.)</li>

    <li>Edit email templates that the system uses when sending
      automatic email to users (e.g. "Dear &lt;insert name&gt;, thank
      you for your order.  We received your order on &lt;insert
      date&gt;, etc.").</li>
    
    <li>View statistics and reports on issues/interactions
      (e.g. interactions by customer service rep, issues by issue
      type).</li>

  </ul>
  </ul>

  <h3>Other</h3>

  <ul>
    <li>Data entered or modified by site administrators is audited, so
      you can see:</li>

  <ul>
    <li>who made the changes</li>
    <li>when the changes were made</li>
    <li>what changed</li>
    <li>the history of all states the data have been in (so your data are never lost)</li>
  </ul>
  
    <li>All of the user display pages are templated. This allows
      designers to change the look and feel of the site without
      mucking around in Tcl or SQL code.</li>

    <li>The system logs potential problems it encounters (e.g. failed
      credit card transactions) and allows site administrators to view
      the problems and mark them "resolved".</li>

  </ul>
