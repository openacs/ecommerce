<master src=master>
<property name=title>Features of the Ecommerce Module</property>

Some of the high-level features of the Ecommerce Module:

<p>

<b>Products</b>

<ul>

<li>Products are divided into categories (like books, journals, ...),
subcategories (computer, fiction, ...), and
subsubcategories (operating systems, web publishing, ...) which are set
by the site adminstrator (if desired).  Products
can belong to as many categories/subcategories/subsubcategories
as needed.  Users can search by category/subcategory/subsubcategory and the site
administrator can make product recommendations by category/subcategory/subsubcategory.

<p>

<li>Via simple forms, the site administrator can upload any desired
information about products either into the Oracle database or into the
file system.
Standard product information such as product name, regular price, etc.,
and admin-defined custom fields are collected in the database.  Pictures
of the product and other formatted info like sample chapters, for instance, are uploaded into the file system.
<p>

<li>Users can input comments and ratings of products.  The site administrator
can choose to: a) allow all comments, b) allow comments after administrator approval, or c) disallow all comments.

<p>

<li>The site administrator can input professional reviews of the products.

<p>

<li>The site administrator can specify whether the product should be
displayed 
when the user does a search. For example, they might not want the product
to display if the product is part of a series or if the product is the hardcover version of a book that also exists in paperback

<p>

<li>Links between products: the site administrator can specify that one
product always links to other product(s) on the product-display page.

<p>

<li>Products can be listed before they are available for sale.  The site administrator
decides whether customers are allowed to preorder items or if they are not allowed
to order until the date that the products become available.

<p>

<li>A product can have a lower, introductory price.  It can also have
a limited-time sale price, and a limited-time special offer price which is given only to those who have the special
offer code in their URL.  

<p>

<li>The site administrator determines the geographical regions in which
tax should be charged.

<p>

<li>Shipping costs are determined by the site administrator as a base cost
+ a certain amount per additional item, or the cost can be
based on weight.  Additional amounts are charged for express shipping, if
allowed.

</ul>

<p>


<b>Personalization</b>

<ul>

<li>Users are recognized, if possible, when they enter the site

<p>

<li>Users can be placed into user classes (student, publisher, ...)
either by themselves (with site administrator approval) or by the
site administrator.

<p>

<li>Members of user classes can be given different views of the
site, different prices for each product, and different product
recommendations.

<p>

<li>A user's purchasing history as well as browsing history is
stored.  Product recommendations can be made based on both
histories.

<p>

<li>Frequent buyers can be recognized and rewarded

<p>

<li>The site will automatically calculate what other products were
most popular among people who bought a given product

</ul>

<p>

<b>Ordering</b>

<ul>
<li>Shopping cart interface: users select items to put into their shopping cart and then go to their cart when they want to "check out".  The shopping cart is editable (similar to Amazon.com)

<p>

<li>If a user is not ready to order yet, they can store their order and
come back to it later (similar to Dell.com)

<p>

<li>User receives an acknowledgment web page and email when their order
is confirmed.

<p>

<li>The user can reuse an address for billing or shipping that they
previously entered on the site and, if the site administrator has 
chosen to store credit card data, they can reuse previous credit cards.

<p>

<li>The user's credit card is authorized at the time that they confirm
their order.  The card is billed automatically only after the site administrator
marks that the order has been shipped.

<p>

<li>The site administrator can issue electronic gift certificates to users.

<p>

<li>The site administrator is able to give refunds to a user if the user returns all or
part of their order.

<p>

<li>Customers can view their order history and track their packages.

<p>

<li>Customers can purchase gift certificates for other people.  A random claim check is generated at the time of purchase and emailed to the recipient.  The recipient is then able to use their gift certificate when they make purchases on the site (until the certificate expires).

</ul>


<b>Community</b>

<ul>

<li>Users can sign up for mailing lists based on the product categories they
are interested in.

<p>

<li>Most importantly, since the Ecommerce Module is tied in with the rest
of the ArsDigita Community System, a more complete picture of the customer (Q &amp;
A forum postings, Classified Ads, etc.) is known than in a stand-alone
ecommerce system 

</ul>

<b>Customer Service</b>

<ul>

<li>A complete customer service submodule which allows customer service reps to:

   <ul>
   <li> receive and respond to customer inquiries via email (includes a spell-checker!)
   <li> record all customer interactions and issues (whether by phone/fax/email/etc.)
   <li> categorize issues
   <li> view complete customer interaction and purchase histories
   <li> send email using the "canned text" system which allows them to automatically insert commonly-used paragraphs into their emails
   <li> "spam" groups of users based on various criteria (date of last visit, number of purchases, pages they've visited, mailing lists they've signed up for, etc.)
   <li> edit email templates that the system uses when sending automatic email to users (e.g. "Dear &lt;insert name&gt;, thank you for your order.  We received your order on &lt;insert date&gt;, etc.")
   <li> view statistics and reports on issues/interactions (e.g. interactions by customer service rep, issues by issue type)
   </ul>


</ul>

<b>Other</b>

<ul>
<li>Data entered or modified by site administrators is audited,
so you can see:

  <ul>
  <li>who made the changes
  <li>when the changes were made
  <li>what changed
  <li>the history of all states the data have been in (so your data are never lost)
  </ul>
  
<p>

<li>All of the user display pages are templated, with templates stored
in a separate directory from the rest of the site.  This allows
designers to change the look and feel of the site without
mucking around in Tcl or SQL code. 

<p>

<li>The system logs potential problems it encounters (e.g. failed credit card
transactions) and allows site administrators to view the problems and mark them "resolved".

</ul>

<b>What's Coming in the Next Version</b>

<ul>
<li>Support for multiple retailers. (Includes an extranet for approved retailers
to upload price and stock information about products they have for sale.)
<p>
<li>Integration with the ACS Graphing Package to show colorful sales reports.
<p>
<li>An online Help system.
</ul>

