<master src=master>
<property name=title>Technical Details of the Ecommerce Module</property>

<h3>Setup</h3>

<ul>
<li>This module requires Oracle 8i.
<p>
<li>Install CyberCash by following the instructions for the
<a href="http://arsdigita.com/free-tools/shoppe">ArsDigita Shoppe</a>.
(Note: it can take a few weeks for your bank and CyberCash to get your
account ready, so get started on that right away!)
<blockquote>
<p>You can start testing your system with the included CyberCash emulator by following these steps:
<p>
<code><pre>
$ cd /web/<i>your_service_name</i>/packages/ecommerce/tcl/
$ mv cybercash-emulator-procs.tcl.for.testing cybercash-emulator-procs.tcl
</pre></code>
<p>restart your server

<p>The emulator is useful, but far from perfect.  Currently, it works for authorizing, but it bombs when called from ec_unsettled_transactions.  There is trouble  with a bad table name (sh_orders) and a bad column (price_charged).  It's clearly meant for <a href="http://arsdigita.com/free-tools/shoppe">ArsDigita Shoppe</a> and hasn't been converted completely.  This means that marked orders are never settled while using the emulator.  If you fix the emulator, please send a patch to <a href="mailto:janine@furfly.net">janine@furfly.net</a>.

<p>When you get a real CyberCash account, REMEMBER TO DISABLE THE EMULATOR!
</blockquote>

<p>

<li>These are the files in this E-commerce release that you need to have to run the package:
  <ul>
  <li><a href="http://furfly.net/downloads">ACS Geotables Package</a> for needed states and country code data 
  <li>data model in packages/ecommerce/sql/ecommerce*.sql
  <li>documentation in packages/ecommerce/www/doc/*
  <li>scripts in packages/ecommerce/www
  <li>admin scripts in packages/ecommerce/www/admin/
  <li>ADP templates in packages/ecommerce/www/templates/
  <li>tcl procs in packages/ecommerce/tcl
  <li>ecommerce parameters that can be reached from /admin/site-map/ (after mounting an instance of the E-commerce application)
  <!-- <li>a little proc ad_return_warning in ad-defs -->
  </ul>

<p><font color=red>This should be updated to outline the process of grabbing the package.</font>

<p>

<li>Install the <a href="http://furfly.net/downloads">ACS Geotables</a> package.

<!-- <p>
    Load the <code>states, country_codes</code> and <code>counties</code>
tables using the <code>load-geo-tables</code> shell script in the
<code>/web/<i>service_name</i>/www/install</code> directory.
<pre>
$ cd /web/<i>service_name</i>/www/install
$ ./load-geo-tables <i>service_name</i>/<i>database_password</i>
</pre>

You should see a long set of text scroll by.  It should terminate with
lines that look like this, but the numbers may be different.
<pre>
loading currency_codes.ctl...

SQL*Loader: Release 8.1.6.1.0 - Production on Sun Jun 11 18:15:36 2000

(c) Copyright 1999 Oracle Corporation.  All rights reserved.

Commit point reached - logical record count 64
Commit point reached - logical record count 128
Commit point reached - logical record count 162
loading states.ctl...

SQL*Loader: Release 8.1.6.1.0 - Production on Sun Jun 11 18:15:44 2000

(c) Copyright 1999 Oracle Corporation.  All rights reserved.

Commit point reached - logical record count 64
Commit point reached - logical record count 69
</pre>

<p>

Note: this module also relies on you having the tools package, the style package, and the audit tool installed.
-->

<p>

<li>Install the <a href="http://furfly.net/downloads">Ecommerce</a> package.

<p>

<li>ImageMagick must be installed (either in /usr/local/bin/ or elsewhere
if you're <a href="http://www.arsdigita.com/doc/security">running your server chrooted</a>)
if you want thumbnails
to be automatically created.  For information on ImageMagick (which is
free), see <a href="http://photo.net/wtr/thebook/images">Chapter 6:
Adding Images to Your Site</a> of Philip and Alex's Guide to Web
Publishing.

<p>
<li>You'll want to setup a means of using SSL for secure transactions, check <a href="http://opennsd.org">OpenNSD.org</a> or <a href="http://aolserver.com">AOLServer.com</a> for modules for SSL and follow instructions for using them.

<p>
<li>Create instance of Ecommerce Package using the /admin/site-map/ on your server.
	<ul>
	<li>Create a new subfolder where you want to mount it.
	<p>Make sure you have a matching set of default templates.
	<ul>
	<li><code><pre>$ cd /web/<i>yourserver</i>/packages/ecommerce/www/templates/
$ mkdir <i>your_new_subfolder</i>
$ cp store/* <i>your_new_subfolder</i>/
</pre></code>	
	<li>Create a new application for that mount point that is an E-commerce application.
	<li>Set parameters for the instance (see below).
	</ul>

<p>
<li>A /web/<i>yourserver</i>/data/ecommerce/product directory is needed to hold the products'
supporting files (it's outside the web root so that no uploaded supporting files
can be executed).  The directory has to be writeable by nsadmin.  (You can change the directory by editing EcommerceDataDirectory and ProductDataDirectory in your parameters .ini file.)
<p>MAKE SURE THE CORRESPONDING PARAMETERS FOR THE PACKAGE ARE SET TO MATCH IN THE NEXT STEP!
<p>


<li>Based on the site owner's publishing decisions, the ecommerce parameters
need to be edited via /admin/site-map/.  Make sure to do the following:
	<ul>
	<li>Make sure E-commerce is enabled, EnabledP should equal 1 in the ecommerce section.
	<li>Complete the SSL section fully
	<li>Pay particular attention to the technical section:
	<ul>
	<li>CustomerServiceEmailAddress should be set to some real email address
	<li>Make sure to replace <i>yourservername</i> in EcommerceDataDirectory with the correct path!  This parameter should also have a trailing slash!
	<li>ProductDataDirectory should have a trailing slash.
	<li>ImageMagickPath could vary on your machine, hunt down the <i>convert</i> command on your system and update this path.
	</ul>
        </ul>	
	
<p>Note that you should hit <i>set parameters</i> for each section and then flush the cache of ecommerce parameters by restarting your server (this is something specific to parameters in ecommerce).

<p>

<li><font color=red>May not be accurate anymore</font>
<p>The page templates display correctly only if you're using fancy ADP parsing.
To do this, make sure that this is in your server .ini file (replacing yourserver
with the name of your server):

<blockquote>
<code>[ns/server/acs/adp/parsers]<br>
fancy=.adp</code>
</blockquote>

<p>

<li>Either find a copy of the <code>zip_codes</code> table to import (ArsDigitans know where
to find it but unfortunately we can't redistribute it because it's licensed),
or delete the little bit of code that uses it.

<p>

<li>Qmail must be installed on your system (it may require special setup
if you're <a href="http://www.arsdigita.com/doc/security">running your server chrooted</a>).

<p>

<li>Optional:  The E-commerce Package includes a customized version of the registration/login/logout pipeline which handles the transition to secure logins a bit more gracefully than the ACS Subsites Package.  You may want to patch the ACS Subsites and ACS TCL packages to match the behavior of the E-commerce Package.  See the <a href="kernel-patches">directions for applying the patch</a>. 

<p>

<li>Optional:  If you want to have products be "visible" to the Site Wide Search package then you need to install the <a href="http://arsdigita.com/acs-repository/">Site Wide Search Package</a>, including all of its requirements for installation.  During the installation of SWS or after run packages/ecommerce/sql/ec-products-sws-setup.sql to add products to your interMedia index.  <font color=red>Note: At this time (Version 4.0a, April 6th, 2001) the interface to SWS has a bug (quite possibly the bug is actually in SWS) that prevents it from working.  See the <a href="release">Release Notes</a> for a bit more detail.  If you come up with a fix, send a patch to <a href="mailto:wtem@olywa.net">wtem@olywa.net</a>.</font>
</ul>

<h3>Under the Hood</h3>

This is provided just for your own information.  You may never need
to know any of it, but it may prove useful if something goes wrong or
if you want to extend the module.

<ul>

<li><b>Financial Transactions</b>
<p>
A financial transaction is inserted whenever a credit card
authorization to charge or refund is made.  These transactions may
or may not be carried through to fulfillment.  The specifics:
<p>
When an order is placed, an authorization is done for the full
cost of the order, so a row is inserted into <code>ec_financial_transactions</code>.
This row has a unique <code>transaction_id</code> and it is tied to the order
using the <code>order_id</code>.  This isn't captured yet (not until
the items ship).
<p>
When a shipment is made, if it's a full shipment of the order, the
financial transaction inserted when the order is first placed
is ready to be captured (<code>to_be_captured_p</code> becomes 't' and the
system attempts to mark and capture it).
<p>
However, if only a partial shipment is made, a new authorization has
to be made (therefore a new row is inserted into <code>ec_financial_transactions</code>, <code>to_be_captured_p</code> is set to 't' and the
system attempts to mark and capture it).

<p>
When a refund is made, a row is also inserted into <code>ec_financial_transactions</code>.
A refund is only inserted if it is definite that it needs to be captured,
so there is no need to set <code>to_be_captured_p</code> if <code>transaction_type</code>='refund'.
<p>
Scheduled procs go around and do the follow-through (making sure everything
is marked/settled) for every transaction that needs to be captured.
<p>
<b><li>Gift Certificates</b>
<p>
Each customer has a gift certificate balance (it may be $0.00), which you
can determine by calling the PL/SQL function <code>ec_gift_certificate_balance</code>.  Different chunks of a customer's balance may expire at different
times because every gift certificate that is issued has an expiration date.
<p>
When the system applies a customer's gift certificate balance to an order,
it begins by using the ones that are going to expire the soonest and continues
chronologically until either the order is completely paid for or until the
customer's gift certificates run out.  If only part of a gift certificate is
used, the remaining amount can be used later.
<p>
If a customer purchases a gift certificate for someone else, the recipient
(who may or may not be a registered user of the site) is emailed a claim
check that they can use to retrieve the gift certificate and have it
placed in their gift certificate balance.  Note: "retrieving" a gift
certificate is equivalent to inserting the <code>user_id</code> of the
owner into <code>ec_gift_certificates</code>.  Retrieved gift certificates
always belong to registered users because gift certificates can
only be retrieved during the course of placing an order, at which time
an unregistered user becomes registered.
<p>
Site administrators can issue gift certificates to customers at will.
In this case, no claim check is generated.  The gift certificate is
automatically assigned to that <code>user_id</code>.
<p>
<b><li>Order States</b>
<p>
Order states are discussed in detail in <a href="ecommerce-operation">Operation of the Ecommerce Module</a>.  That should be read to understand the
concepts of order states and item states and to see the finite state machines
involved.
<p>
Below is a very boring diagram of what order state the order should be in
given the item state of the items in that order.  This diagram only
covers the order states VOID, PARTIALLY_FULFILLED, FULFILLED, and
RETURNED.  All other order states are grouped under OTHER.  In all other
order states, the items are of a uniform item state,
so it is either quite obvious what the order state will be or it is completely
independent of what the order state will be.
<p>
An "X" in a column implies that there is at least one (possibly many) item
in that item state.
<p>
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

<p>

<b><li>Shopping Cart Definitions</b>
<p>

 <dl>
 <dt>Shopping Cart</dt>
 <dd>An IN_BASKET order with the same user_session_id as in the user's cookie.</dd>
 <dt>Saved Cart</dt>
 <dd>An IN_BASKET order with the user_id filled in, no user_session_id filled in, and saved_p='t'</dd>
 <dt>Abandoned Cart</dt>
 <dd>An IN_BASKET order with saved_p='f' and a user_session_id that doesn't correspond to the user_session_id in anyone's cookie (e.g. the user's cookie expired or they turned cookies off).  There's no way of determining whether a shopping cart has been abandoned.  These are different from expired orders which are automatically put into the order state EXPIRED if they're still IN_BASKET after N days, where N is set in the .ini file)
 </dl>

<p>
<b><li>Credit Card Pre-Checking</b>
<p> 
Before credit card information is sent out to CyberCash for authorization,
some checking is done by the module to make sure that the credit card
number is well-formed (using the procedure <code>ec_creditcard_precheck</code> which can be found in /tcl/ecommerce-credit).  The procedure checks the length of the credit card number, makes sure
it starts with the right digit for the card type, and does a LUHN-10
check (that's a checksum which can't determine whether the number is a
valid credit card number but which determines whether it's even <i>possible</i>
for it to be a valid credit card number).
<p>
This procedure only encompasses the three most common credit card types:
MasterCard, Visa, and American Express.  It can quite easily be extended
to include other credit card types.
<p>
<b><li>Automatic Emails</b>
<p>
When you install the system, there are 7 automatic emails included that
are sent to customers in common situations (e.g., "Thank you for your
order" or "Your order has shipped").  If a site administrator adds a 
new email template using the admin pages, you will have to create a
new procedure that does all the variable substitution, the actual
sending out of the email, etc.  This should be easy.  Just copy any
one of the 7 autoemail procedures in /tcl/ecommerce-email (<i>except</i>
for <code>ec_email_gift_certificate_recipient</code>, which is unusual).
Then invoke your new procedure anywhere appropriate (e.g. the email that
says "Thank you for your order" is invoked by calling
<code>ec_email_new_order $order_id</code> after the order has been
successfully authorized).
<p>
<b><li>Storage of Credit Card Numbers</b>
<p>
Credit card numbers are stored until an order is completely fulfilled.
This is done because a new charge might need to be authorized if a
partial shipment is made (we are forced to either capture the amount that
a charge was authorized for or to capture nothing at all - we can't capture any
amount in between; therefore, we are forced to do a new authorization
for each amount we are going to charge the user).  A new charge also might
need to be authorized if a user has asked the site administrator to add
an item to their order.
<p>
If you've decided not to allow customers to reuse their credit cards,
their credit card data is removed periodically (a few times a day) by
<code>ec_remove_creditcard_data</code> in
/tcl/ecommerce-scheduled-procs (it removes credit card numbers for
orders that are FULFILLED, RETURNED, VOID, or EXPIRED).
<p>
If you've decided to allow customers to reuse their credit cards, their
credit card information is stored indefinitely.  This is not recommended
unless you have top-notch, full-time, security-minded system administrators.
The credit card numbers are not encrypted in the database because there
isn't much point in doing so; our software would have to decrypt the 
numbers anyway in order to pass them off to CyberCash, so it would be
completely trivial for anyone who breaks into the machine to grep for
the little bit of code that decrypts them.  The ideal thing would be
if CyberCash were willing to develop a system that uses PGP so that we
could encrypt credit card numbers immediately, store them, and send them
to CyberCash at will.  <i>Philip and Alex's Guide to Web Publishing</i> says:

<blockquote>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;What would plug this last hole is for CyberCash to give us a public key. We'd encrypt the consumer's card
number immediately upon receipt and stuff it into our Oracle database. Then if we needed to retry an
authorization, we'd simply send CyberCash a message with the encrypted card number. They would decrypt the
card number with their private key and process the transaction normally. If a cracker broke into our server, the
handful of credit card numbers in our database would be unreadable without Cybercash's private key. The same
sort of architecture would let us do reorders or returns six months after an order. <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;CyberCash has "no plans" to do anything like this. 
</blockquote>
Note 1: If you or the company you work for are very powerful or
influential, perhaps you can put a little fire under CyberCash's bum
to get them to make that change (Levi's couldn't convince CyberCash
when we were doing a project for them).  It's not like it would be
that hard for CyberCash to implement it.
<p>
Note 2: The above discussion <i>does not</i> mean that the credit
card numbers go over the network unencrypted.  CyberCash's closed-source
software on your machine encrypts the numbers immediately before sending them out.
<p>
Note 3: If you want to let your customers reuse their old credit cards,
you can reduce some of the risk by manually removing old credit card data
once in a while (at least then there will be fewer numbers in your database for
the crackers to steal).  To clear out the unnecessary credit card data, just 
run a procedure like <code>ec_remove_creditcard_data</code> (in
/tcl/ecommerce-scheduled-procs) but get rid of the if statement that
checks whether <code>SaveCreditCardDataP</code> is 0 or 1.
<p>
<b><li>Price Calculation</b>
<p>
The site administrator can give the same product different prices for 
different classes of users.  They can also put products on sale over
arbitrary periods of time (sale prices may be available to all 
customers or only to ones who have the appropriate <code>offer_code</code>
in their URL).  
<p>
The procedure <code>ec_lowest_price_and_price_name_for_an_item</code> in /tcl/ecommerce-money-computations determines the lowest price that a given user
is entitled to receive based on what user classes they're in and what
<code>offer_code</code>s they came to product with.  Their <code>offer_code</code>s are stored, along with their <code>user_session_id</code>, in
<code>ec_user_session_offer_codes</code> (we decided to store this in 
the database instead of in cookies because it was a slightly more efficient
method, although either implementation would have worked).  One minor
complication to this is that if a user saves their shopping cart, we want
them to get their special offer price, even though they may be coming
back with a different <code>user_session_id</code>; therefore, upon retrieving saved
carts, the <code>offer_code</code>s are inserted again into
<code>ec_user_session_offer_codes</code> with the user's current 
<code>user_session_id</code> (we had to associate <code>offer_code</code>s
with <code>user_session_id</code> as opposed to <code>user_id</code>
because someone with an <code>offer_code</code> shouldn't be prevented
from seeing the special offer price if they haven't logged in yet).
</ul>

The above items are just things that I've found myself explaining to
others or things that I think will be useful for people extending
this module.  Obviously the bulk of the module's code has not been
discussed here. If you have any questions, please email Eve at
<a href="mailto:eveander@arsdigita.com">eveander@arsdigita.com</a>
or Janine at <a href="mailto:janine@furfly.net">janine@furfly.net</a>


