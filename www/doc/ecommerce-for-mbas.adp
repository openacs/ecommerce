<!-- <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"> -->

<master>
  <property name=title>@title@</property>
  <property name="signatory">@signatory@</property>

  <h2>@title@</h2>
  <table width="100%">
    <tbody>
      <tr>
	<td align="left">@context_bar@</td>
      </tr>
    </tbody>
  </table>
  <hr>

  <p>The big decision:</p>

  <ol type="A">
    <li>you are the retailer</li>
    <li>you send all orders to one retailer</li>
    <li>you offer products and send orders to multiple retailers</li>
    <li>you let an arbitrary number of retailers come to your site and
      build shops (Yahoo! Store; Amazon Z Shops)</li>
  </ol>

  <p>OpenaACS supports the first three ways of doing business and will
  eventually support the last one (clone of Yahoo! Store).</p>

  <h3>High-level features</h3>

  <p>If your imagination is limited, you can think of this as
  "Amazon.com in a box".  Is is it impressive to do everything that
  Amazon does?  Not really.  Ecommerce is a fast-moving field.
  Packaged software always embodies last year's business ideas.  The
  interesting thing is how quickly one can extend an open-source
  software system to accomodate the latest business ideas.</p>

  <h3>Feature List</h3>

  <blockquote>
    <table cellspacing="3">
      <tbody>
	<tr>
	  <th>in MBA-speak</th>
	  <th>translation for programmers</th>
	</tr>
	<tr>
	  <td valign="top">catalog engine</td>
	  <td valign="top">Database table (<code>ec_products</code>)
	    plus extra tables for mapping to categories,
	    subcategories, and subsubcategories; bulk upload from
	    structured data</td>
	</tr>
	<tr>
	  <td valign="top">e-recommendation engine</td>

	  <td valign="top">Datbase table
	    (<code>ec_product_recommendations</code>) mapping products
	    to categories, subcategories, for everyone or only a
	    particular class of user</td>

	</tr>
	<tr>
	  <td valign="top">e-review technology</td>

	  <td valign="top">Database tables for professional reviews
	    and customer-contributed reviews</td>

	</tr>
	<tr>
	  <td valign="top">shopping cart</td>

	  <td valign="top">Database tables (<code>ec_user_sessions,
	  ec_orders, ec_items</code>)</td>

	</tr>
	<tr>
	  <td valign="top">real-time credit card billing</td>
	  <td valign="top">Payment gateway interfaces</td>
	</tr>
	<tr>
	  <td valign="top">user tracking</td>
	  <td valign="top">Log every page view and search</td>
	</tr>
	<tr>

	  <td valign="top">integrated customer service (telephone,
	  fax, email, and Web)</td>

	  <td valign="top">All interactions logged into same Database
	  table; inbound <a
	  href="http://www.arsdigita.com/doc/email-handler">ACS 3.4.8
	  email handler</a> (Perl script); call center staff sit at
	  Web browsers and use the @package_name@ admin pages</td>

	</tr>
	<tr>
	  <td valign="top">CRM</td>

	  <td valign="top">Write custom rules for <a
	  href="http://www.arsdigita.com/doc/crm">standard ACS 3.4.8
	  CRM module</a> (to be ported...)</td>

	</tr>
	<tr>
	  <td valign="top">intelligent agent</td>
	  <td valign="top">Database query for "users who bought X also bought Y"</td>
	</tr>
	<tr>
	  <td valign="top">content management with visual interface</td>
	  <td valign="top">Web forms plus auditing of all changes</td>
	</tr>
	<tr>
	  <td valign="top">discounts for different classes of user</td>

	  <td valign="top">Example: MIT Press wants to sell journals
	    at different rates for individual, institutional, and
	    student subscriptions</td>

	</tr>
	<tr>
	  <td valign="top">cross-sales platform</td>

	  <td valign="top">Database table of "if you're interested in
	    X, you probably also should buy Y"; links are
	    unidirectional</td>

	</tr>
	<tr>
	  <td valign="top">object-oriented design</td>

	  <td valign="top">Per-publisher custom fields table to add
	    arbitrary attributes to products</td>

	</tr>
	<tr>
	  <td valign="top">intelligent parametric and free-text search engine</td>

	  <td valign="top"><code>pseudo_contains</code> if you want to
	    have an easy Database dbadmin life; <code>Contains</code>
	    (Intermedia text) if you don't; limit to category at
	    user's option</td>

	</tr>
	<tr>
	  <td valign="top">gift certificates</td>
	  <td valign="top">Auditing and mandatory expiration </td>
	</tr>
	<tr>
	  <td valign="top">enterprise-scale e-business solution</td>
	  <td valign="top">Add more processors to your Database server</td>
	</tr>
	<tr>
	  <td valign="top">highly scalable transaction engine</td>
	  <td valign="top">Orders are inserted into a database table</td>
	</tr>
	<tr>
	  <td valign="top">XML-enabled</td>
	  <td valign="top">Use the nsxml module for AOLServer</td>
	</tr>
      </tbody>
    </table>
  </blockquote>

  <h3>Bottom line</h3>

  <p>If a closed-source ecommerce package doesn't do exactly what you
  want, you're out of business.  If the company behind a closed-source
  ecommerce package goes out of business, so will you.  If the company
  behind a closed-source ecommerce adopts a different "business
  model", you're screwed.</p>

  <p>If you're even tempted to adopt a commercial ecommerce system
  from a company other than IBM, Oracle or SAP (three enterprise
  software vendors that seem likely to be around for awhile), read the
  iCat story towards the end of <a
  href="http://www.arsdigita.com/asj/using-the-acs">Using the
  ArsDigita Community System</a>


