<master src=master>
<property name=title>Ecommerce Module (explained for MBAs)</property>

The big decision:

<ol type=A>

<li>you are the retailer

<li>you send all orders to one retailer

<li>you offer products and send orders to multiple retailers

<li>you let an arbitrary number of retailers come to your site and build
shops (Yahoo! Store; Amazon Z Shops)

</ol>

ACS supports the first three ways of doing business and will eventually
support the last one (clone of Yahoo! Store).


<h3>High-level features</h3>

If your imagination is limited, you can think of this as "Amazon.com in
a box".  Is is it impressive to do everything that Amazon does?  Not
really.  Ecommerce is a fast-moving field.  Packaged software always
embodies last year's business ideas.  The interesting thing is how
quickly one can extend an open-source software system to accomodate the
latest business ideas.

<h3>Feature List</h3>

<blockquote>
<table cellspacing=3>
<tr>
<th>in MBA-speak
<th>translation for programmers
</tr>
<tr>
<td valign=top>catalog engine
<td valign=top>Oracle table (<code>ec_products</code>) plus 
extra tables for mapping to categories, subcategories, and
subsubcategories; bulk upload from structured data
</tr>
<tr>
<td valign=top>e-recommendation engine
<td valign=top>Oracle table (<code>ec_product_recommendations</code>)
 mapping products to categories, subcategories, for everyone or only a
particular class of user
</tr>
<tr>
<td valign=top>e-review technology
<td valign=top>Oracle tables for professional reviews and customer-contributed
reviews
</tr>

<tr>
<td valign=top>shopping cart 
<td valign=top>Oracle tables (<code>ec_user_sessions, ec_orders, ec_items</code>)
</tr>
<tr>
<td valign=top>real-time credit card billing 
<td valign=top>CyberCash and CyberSource interfaces
</tr>
<tr>
<td valign=top>user tracking
<td valign=top>log every page view and search
</tr>
<tr>
<td valign=top>integrated customer service (telephone, fax, email, and Web)
<td valign=top>all interactions logged into same Oracle table; inbound
<a href="http://www.arsdigita.com/doc/email-handler">ACS 3.4.8 email handler</a> (Perl script); call
center staff sit at Web browsers and use the <%= [ec_url] %>admin/ pages
</tr>
<tr>
<td valign=top>CRM 
<td valign=top>write custom rules for <a href="http://www.arsdigita.com/doc/crm">standard ACS 3.4.8 CRM module</a> (to be ported...)
</tr>
<tr>
<td valign=top>intelligent agent
<td valign=top>Oracle query for "users who bought X also bought Y"
</tr>
<tr>
<td valign=top>content management with visual interface
<td valign=top>Web forms plus auditing of all changes
</tr>
<tr>
<td valign=top>discounts for different classes of user
<td valign=top>Example:  MIT Press wants to sell journals
at different rates for individual, institutional, and student subscriptions
</tr>
<tr>
<td valign=top>cross-sales platform
<td valign=top>Oracle table of "if you're interested in X, you probably
also should buy Y"; links are unidirectional
</tr>
<tr>
<td valign=top>object-oriented design
<td valign=top>per-publisher custom fields table to add arbitrary
attributes to products
</tr>
<tr>
<td valign=top>intelligent parametric and free-text search engine
<td valign=top><code>pseudo_contains</code> if you want to have an easy
Oracle dbadmin life; <code>Contains</code> (Intermedia text) if you
don't;
limit to category at user's option
</tr>
<tr>
<td valign=top>gift certificates
<td valign=top>auditing and mandatory expiration 
</tr>
<tr>
<td valign=top>enterprise-scale e-business solution
<td valign=top>add more processors to your Oracle server
</tr>
<tr>
<td valign=top>highly scalable transaction engine
<td valign=top>orders are inserted into Oracle table
</tr>
<tr>
<td valign=top>XML-enabled
<td valign=top>download free Java XML libraries from Oracle
</tr>

</table>
</blockquote>


<h3>Bottom line</h3>

If a closed-source ecommerce package doesn't do exactly what you want,
you're out of business.  If the company behind a closed-source ecommerce
package goes out of business, so will you.  If the company behind a
closed-source ecommerce adopts a different "business model", you're
screwed.  

<p>

If you're even tempted to adopt a commercial ecommerce system from a
company other than IBM, Oracle or SAP (three enterprise software vendors
that seem likely to be around for awhile), read the iCat story towards
the end of <a
href="http://photo.net/wtr/using-the-acs">http://photo.net/wtr/using-the-acs</a>


